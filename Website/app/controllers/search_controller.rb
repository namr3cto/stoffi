# -*- encoding : utf-8 -*-
# The business logic for the search engine.
#
# Flow:
#  1. User enters query into search box
#  2. suggest() fetches similar search queries for auto-complete
#  3. User presses Enter
#  4. index() saves the query and renders a skeleton result view
#  5. The view uses AJAX to load the actual results from fetch()
#  6. fetch() sends query to backends in search/ folder
#  7. The results are injected into the page
#
# For API calls the index() method will directly fetch results
# and return them.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2013 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

#require 'backend/lastfm'
#require 'backend/youtube'
#require 'backend/soundcloud'

class SearchController < ApplicationController
	respond_to :html, :mobile, :embedded, :json, :xml
	
	def flush	
		Artist.delete_all
		Album.delete_all
		Song.delete_all
		Event.delete_all
		Search.delete_all
		Image.delete_all
		Source.delete_all
	end

	def suggest
		@query = query_param
		@suggestions = []
		if @query.present?
			page = request.referer
			pos = origin_position(request.remote_ip)
			long = pos[:longitude]
			lat = pos[:latitude]
			loc = I18n.locale.to_s
			user = user_signed_in? ? current_user.id : -1
			@suggestions = Search.suggest(@query, page, long, lat, loc, user)
		end
		respond_with(@suggestions)
	end
	
	def index
		#flush
		
		redirect_to action: :index and return if params[:format] == "mobile"
		@search = save_search
		@query = query_param
		@categories = category_param
		@sources = source_param
		@title = e(@query)
		@description = t("index.description")
		
		respond_with(@search) and return if request.format == :html
			
		# request is API call, so we call fetch and return the results
		respond_with(@search.do)
	end
	
	def fetch
		@search = Search.find(params[:id])
		head :unprocessable_entity and return if @search.query.blank?
		@results = @search.do
		respond_with(@results, layout: false)
	end
	
	private
	
	def query_param
		q = params[:q] || params[:query] || params[:term] || ""
		CGI::escapeHTML(q)
	end
	
	def category_param
		default = 'artists|songs|devices|playlists|events|albums'
		c = (params[:c] || params[:cat] || params[:categories] || params[:category] || default)
		c.split(/[\|,]/)
	end
	
	def source_param
		default = 'soundcloud|youtube|jamendo|lastfm'
		c = (params[:s] || params[:src] || params[:sources] || params[:source] || default)
		c.split(/[\|,]/)
	end
	
	def limit_param
		[50, (params[:l] || params[:limit] || "5").to_i].min
	end
	
	def offset_param
		[50, (params[:o] || params[:offset] || "0").to_i].min
	end
	
	# Save a search
	#
	# This is later used for auto-complete suggestions, and
	# for knowing when a cache is dirty
	def save_search
		pos = origin_position(request.remote_ip)
		s = Search.new
		s.query = query_param
		s.longitude = pos[:longitude]
		s.latitude = pos[:latitude]
		s.locale = I18n.locale.to_s
		s.categories = category_param.sort.join('|')
		s.sources = source_param.sort.join('|')
		s.page = request.referer || ""
		s.user = current_user if user_signed_in?
		s.save
		s
	end
end
