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

require 'backend/lastfm'

class SearchController < ApplicationController
	respond_to :html, :mobile, :embedded, :json, :xml
	
	include Backend::Lastfm
	
	def index
		redirect_to :action => :index and return if params[:format] == "mobile"
		@query = query_param
		@categories = category_param
		#save_search unless @query.to_s.empty?
		@title = e(params[:q])
		@description = t("index.description")
		
		render and return if request.format == :html
			
		# API call, so we call fetch and return the results
		@results = get_results(@query, @categories)
		respond_with(@results)
	end

	def suggest
		@query = query_param
		@suggestions = []
		unless @query.to_s.empty?
			page = request.referer
			pos = origin_position(request.remote_ip)
			long = pos[:longitude]
			lat = pos[:latitude]
			loc = I18n.locale.to_s
			user = current_user.id if user_signed_in? else -1
			@suggestions = Search.suggest(q, page, long, lat, loc, user)
		end
		respond_with(@suggestions)
	end
	
	def fetch
		@query = query_param
		respond_with({ error: 'query cannot be empty' }) if @query.to_s.empty?
		@results = get_results(@query, category_param)
		respond_with(@results)
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
	
	def limit_param
		[50, (params[:l] || params[:limit] || "5").to_i].min
	end
	
	def save_search
		begin
			logger.debug "saving query #{query_param}"
			pos = origin_position(request.remote_ip)
			s = Search.new
			s.query = query_param
			s.longitude = pos[:longitude]
			s.latitude = pos[:latitude]
			s.locale = I18n.locale.to_s
			s.categories = category_param
			s.page = request.referer || ""
			s.user = current_user if user_signed_in?
			s.save
		rescue
			logger.error "could not save search for #{query_param}"
		end
	end
	
	def get_results(query, categories)
		hits = []
		hits.concat(parse_hits(Backend::Lastfm.search(query, categories)))
		results = { hits: hits }
		results
	end
	
	def parse_hits(hits)
		max_popularity = hits.collect { |x| x[:popularity] || 0 }.max
		parsed_hits = []
		
		hits.each do |hit|
			
			# turn absolute popularity into relative popularity
			#hit[:popularity] = (hit[:popularity].to_f || 0) / max_popularity
			
			case hit[:type]
			when :artist then
				#Artist.parse_name(hit[:name]).each do |name|
				#	h = { type: :artist, name: name, }
				#end
			end
		end
	end
end
