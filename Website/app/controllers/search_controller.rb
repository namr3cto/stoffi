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
	
	# Some weights and score points
	WEIGHT_SIMILARITY = 1
	WEIGHT_POPULARITY = 5
	
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
		
		hits.each do |h|
			h[:distance] = distance(query, h[:name])
			h[:score] = h[:distance] * WEIGHT_SIMILARITY + h[:popularity] * WEIGHT_POPULARITY
		end
		
		hits = hits.sort_by { |h| h[:score] }.reverse
		
		results = { hits: hits.collect {|h| { name: h[:name], type: h[:type] } } }
		results
	end
	
	def parse_hits(hits)
		
		parsed_hits = []
		parsed_artists = {}
		hits.each do |hit|
			case hit[:type]
			when :artist then
				
				# some artists are named "Foo feat. Bar" so we split
				# the name and divide the popularity among them
				artists = Artist.split_name(hit[:name])
				popularity_pot = hit[:popularity] / artists.count.to_f
				artists.each do |name|
					if parsed_artists.has_key? name
						parsed_artists[name][:popularity] += hit[:popularity]#popularity_pot
					else
						parsed_artists[name] = {
							popularity: popularity_pot,
							name: name,
							type: :artists
						}
					end
				end
			end
		end
		parsed_hits.concat parsed_artists.values
			
		# turn absolute popularity into relative popularity
		max_popularity = parsed_hits.collect { |x| x[:popularity] }.max
		max_popularity = 1 if max_popularity == 0
		parsed_hits.collect { |x| x[:popularity] /= max_popularity }
		
		return parsed_hits
	end
		
	# calculate the 'distance' between two lists of words
	def distance(str1, str2)
		words1 = str1.downcase.split
		words2 = str2.downcase.split
		len1 = words1.count.to_f
		len2 = words2.count.to_f
		added = (words2 - words1).count.to_f
		kept = len1 - (words1 - words2).count.to_f
		return 0 if kept == 0
		d = kept/len1
		d *= 1 - (added/len2) unless added == 0
		return d
	end
end
