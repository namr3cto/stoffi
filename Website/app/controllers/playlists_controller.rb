# The business logic for playlists.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2015 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

class PlaylistsController < ApplicationController
	
	before_action :set_playlist, only: [:show, :edit, :update, :destroy, :follow]
	oauthenticate except: [ :index, :show ]
	
	respond_to :html, :embedded, :json, :xml
	
	# GET /playlists
	def index
		l, o = pagination_params
		
		@recent = Playlist.is_public.order(created_at: :desc).limit(l).offset(o)
		@weekly = Playlist.is_public.top(from: 7.days.ago).limit(l).offset(o)
		@all_time = Playlist.is_public.top.limit(l).offset(o)
		
		if user_signed_in?
			@user_follows = current_user.following(Playlist)
			@user_all_time = current_user.playlists.limit(l).offset(o)
		end
		
		respond_with(@all_time)
	end
	
	# GET /playlists/by/1
	def by
		l, o = pagination_params
		params[:user_id] = process_me(params[:user_id])
		follows = params[:follows].present?
		
		@user = User.find(params[:user_id])
		
		if follows
			@playlists = @user.following(Playlist)
		else
			@playlists = @user.playlists.where(is_public: 1).limit(l).offset(o)
		end
		
		respond_with(@playlists, include: [ :songs ])
	end

	# GET /playlists/1
	def show
		l, o = pagination_params
		
		unless user_signed_in? && @playlist.user == current_user || @playlist.is_public
			access_denied and return
		end
		
		@channels = ["user_#{@playlist.user.id}"]
		
		t=0
		@head_prefix = "og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# stoffiplayer: http://ogp.me/ns/fb/stoffiplayer#"
		@meta_tags =
		[
			{ property: "og:title", content: d(@playlist.name) },
			{ property: "og:type", content: "music.playlist" },
			{ property: "og:image", content: @playlist.image },
			{ property: "og:url", content: playlist_url(@playlist) },
			{ property: "og:description", content: @description },
			{ property: "og:audio", content: playlist_url(@playlist, protocol: "playlist") },
			{ property: "og:audio:type", content: "audio/vnd.facebook.bridge" },
			{ property: "og:site_name", content: "Stoffi" },
			{ property: "fb:app_id", content: "243125052401100" },
			{ property: "music:creator", content: user_registration_path(@playlist.user) },
		] |
			@playlist.songs.map { |song| { property: "music:song", content: song_url(song) } }
			
		@playlist.paginate_songs(l, o)
		respond_with(@playlist, methods: [ :paginated_songs ])
	end

	# GET /playlists/new
	def new
		@playlist = current_user.playlists.new
		render layout: false
	end

	# GET /playlists/1/edit
	def edit
		not_found('playlist') and return unless owns(Playlist, params[:id])
	end

	# POST /playlists
	def create
		exists = current_user.playlists.find_by(name: params[:playlist][:name]) != nil
		@playlist = Playlist.get(current_user, params[:playlist][:name])
		@playlist.assign_attributes(playlist_params)
		@playlist.is_public = true # TODO: set default in db instead
		success = @playlist.save
		
		if success
		
			begin
				songs = params[:songs]
				unless songs
					body = request.body.read
					if body && body != ""
						begin
							songs = JSON.parse(body)
						rescue
						end
					end
				end
				
				if songs.is_a?(Array)
					songs.each do |track|
						song = Song.get(current_user,
						{
							title: track['title'],
							path: track['path'],
							length: track['length'],
							foreign_url: track['foreign_url'],
							art_url: track['art_url'],
							genre: track['genre'],
							artist: track['artist'],
							album: track['album']
						})
						if song and not @playlist.songs.exists?(song.id)
							@playlist.songs << song
						end
					end
				end
			rescue Exception => err
				logger.error "Could not add songs to playlist"
				logger.error err.message
				logger.error err.backtrace.inspect
			end
			SyncController.send('create', @playlist, request)
			if @playlist.is_public and @playlist.songs.count > 0
				current_user.links.each { |link|
					if exists
						link.update_playlist(@playlist)
					else
						link.create_playlist(@playlist)
					end
				}
			end
		end
		
		respond_to do |format|
			if success
				format.html { redirect_to @playlist }
				format.js { }
				format.json { render json: @playlist, status: :created, location: @playlist }
			else
				format.html { render action: 'new' }
				format.js { render partial: 'shared/dialog/errors', locals: { resource: @playlist, action: :create } }
				format.json { render json: @playlist.errors, status: :unprocessable_entity }
			end
		end
	end

	# PUT /playlists/1
	def update
		not_found('playlist') and return unless owns(Playlist, params[:id])
		
		newProps = Hash.new
		newProps['songs'] = { 'added' => [], 'removed' => [] }
		
		songs = params[:songs]
		
		unless songs
			body = request.body.read
			if body && body != ""
				begin
					songs = JSON.parse(body)
				rescue
				end
			end
		end
		
		if songs
			logger.debug songs.to_yaml
			
			# make sure that params['playlist'] exists
			# so create_properties will run diff check
			params['playlist'] = Hash.new unless params['playlist']
			props = SyncController.create_properties(@playlist, params)
			
			# add songs
			if songs['added']
				songs['added'].each do |track|
					song = Song.get(current_user,
					{
						title: track['title'],
						path: track['path'],
						length: track['length'],
						foreign_url: track['foreign_url'],
						art_url: track['art_url'],
						genre: track['genre'],
						artist: track['artist'],
						album: track['album']
					})
					
					if song and not @playlist.songs.exists?(song.id)
						@playlist.songs << song
						props['songs']['added'] << song
					end
				end
			end
			
			# remove songs
			if songs['removed']
				songs['removed'].each do |track|
					song = Song.find(track['id']) if (track['id'] and not track['id'].starts_with?("tmp_"))
					song = Song.find_by(path: track['path']) if track['path'] and not song
					
					@playlist.songs.delete(song) if song
					
					props['songs']['removed'] << song if song
				end
			end
			
		end
		
		success = @playlist.update_attributes(playlist_params)
		
		if success
			if not @playlist.is_public or @playlist.songs.count == 0
				current_user.links.each { |link| link.delete_playlist(@playlist) }
			elsif @playlist.songs.count > 0
				current_user.links.each { |link| link.update_playlist(@playlist) }
			end
			SyncController.send('update', @playlist, request, props)
		end

		respond_with(@playlist)
	end

	# DELETE /playlists/1
	def destroy
		
		# destroy playlist
		if @playlist.user == current_user
			SyncController.send('delete', @playlist, request)
			current_user.links.each { |link| link.delete_playlist(@playlist) }
			@playlist.destroy
			
		# unfollow playlist
		else
			SyncController.send('execute', @playlist, request, 'unfollow')
			current_user.unfollow @playlist
		end
		respond_with(@playlist)
	end
	
	# PUT /playlists/1/follow
	def follow
		not_found('playlist') and return unless @playlist.is_public
		
		unless current_user.follows? @playlist
			current_user.follow @playlist
			SyncController.send('execute', @playlist, request, 'follow')
		end
		
		respond_with(@playlist)
	end
	
	private

	# Use callbacks to share common setup or constraints between actions.
	def set_playlist
		not_found('playlist') and return unless Playlist.exists? params[:id]
		@playlist = Playlist.find(params[:id])
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def playlist_params
		params.require(:playlist).permit(:name, :user, :is_public)
	end
end
