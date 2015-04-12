# -*- encoding : utf-8 -*-
# The business logic for songs.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2013 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

class SongsController < ApplicationController
	include DuplicatableController
	
	before_action :set_song, only: [:show, :edit, :update, :destroy]

	can_duplicate Song
	oauthenticate interactive: true, except: [ :index, :show ]
	before_filter :ensure_admin, except: [ :index, :show, :create, :destroy ]
	respond_to :html, :xml, :json
	
	# GET /songs
	def index
		@max_items = 12
		
		@recent = Listen.order(created_at: :desc).limit(@max_items).map(&:song)
		@weekly = Song.top(from: 7.days.ago).limit @max_items
		@alltime = Song.top.limit @max_items
		
		if user_signed_in?
			@user_recent = current_user.listens.order(created_at: :desc).limit(@max_items).map(&:song)
			@user_weekly = Song.top(for: current_user, from: 7.days.ago).limit @max_items
			@user_alltime = Song.top(for: current_user).limit @max_items
		end

		respond_with(@weekly)
	end

	# GET /songs/1
	def show
		respond_with(@song, include: :artists)
	end

	# GET /songs/new
	def new
		redirect_to songs_path
	end

	# GET /songs/1/edit
	def edit
		redirect_to song_path(@song)
	end

	# POST /songs
	def create
		@song = Song.get_by_path(params[:song][:path])
		@song = current_user.songs.new(params[:song]) unless @song
		
		if current_user.songs.find_all_by_id(@song.id).count == 0
			current_user.songs << @song
		end
		
		@song.save
		respond_with(@song)
	end

	# PUT /songs/1
	def update
		respond_to do |format|
			if @song.update_attributes(song_params)
				format.html { redirect_to @song }
				format.js { }
				format.json { render json: @song, location: @song }
			else
				format.html { render action: 'edit' }
				format.js { render partial: 'shared/dialog/errors', locals: { resource: @song, action: :update } }
				format.json { render json: @song.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /songs/1
	def destroy
		respond_with(@song)
	end
	
	private

	# Use callbacks to share common setup or constraints between actions.
	def set_song
		not_found('song') and return unless Song.unscoped.exists? params[:id]
		@song = Song.unscoped.find(params[:id])
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def song_params
		params.require(:song).permit(:title, :genres, :artists, :archetype_id, :archetype_type)
	end
end
