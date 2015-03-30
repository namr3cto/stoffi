# -*- encoding : utf-8 -*-
# The business logic for artists.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2013 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

class ArtistsController < ApplicationController
	before_action :set_artist, only: [:show, :edit, :update, :destroy]
	oauthenticate interactive: true, except: [ :index, :show ]
	before_filter :ensure_admin, except: [ :index, :show ]
	respond_to :html, :xml, :json
	
	def index
		l, o = pagination_params
		@recent = Listen.order(created_at: :desc).limit(l).offset(o).map(&:song).map(&:artists).flatten.uniq
		@weekly = Artist.top(from: 7.days.ago).limit(l).offset(o)
		@all_time = Artist.top.limit(l).offset(o)
		
		if user_signed_in?
			@user_recent = current_user.listens.order(created_at: :desc).limit(l).offset(o).map(&:song).map(&:artists).flatten.uniq
			@user_weekly = Artist.top(for: current_user, from: 7.days.ago).limit(l).offset(o)
			@user_all_time = Artist.top(for: current_user).limit(l).offset(o)
		end
		
		respond_with(@all_time)
	end

	def show
		l, o = pagination_params
		@title = @artist.name
		@description = t "artist.description", artist: d(@artist.name)
		@head_prefix = "og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# stoffiplayer: http://ogp.me/ns/fb/stoffiplayer#"
		@meta_tags =
		[
			{ property: "og:title", content: d(@artist.name) },
			{ property: "og:type", content: "stoffiplayer:artist" },
			{ property: "og:image", content: @artist.picture },
			{ property: "og:url", content: @artist.url },
			{ property: "og:site_name", content: "Stoffi" },
			{ property: "fb:app_id", content: "243125052401100" },
			{ property: "og:description", content: t("artist.short_description", artist: d(@artist.name)) },
			{ property: "stoffiplayer:donations", content: @artist.donations.count },
			{ property: "stoffiplayer:support_generated", content: "$#{@artist.donated_sum}" },
			{ property: "stoffiplayer:charity_generated", content: "$#{@artist.charity_sum}" }
		]
		
		@donations = @artist.donations

		@artist.paginate_songs(l, o)
		respond_with(@artist, methods: [ :paginated_songs ])
	end

	def update
		@artist.update(artist_params)
		respond_with(@artist)
	end

	def destroy
		@artist.destroy
		respond_with(@artist)
	end
	
	private

	# Use callbacks to share common setup or constraints between actions.
	def set_artist
		not_found('artist') and return unless Artist.exists? params[:id]
		@artist = Artist.find(params[:id])
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def artist_params
		params.require(:artist).permit(:name)
	end
end
