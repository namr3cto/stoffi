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
	
	# Some weights and score points
	WEIGHT_SIMILARITY = 5
	WEIGHT_POPULARITY = 3
	
	def index
		redirect_to action: :index and return if params[:format] == "mobile"
		@query = query_param
		@categories = category_param
		@sources = source_param
		#save_search @query.present?
		@title = e(params[:q])
		@description = t("index.description")
		
		render and return if request.format == :html
			
		# API call, so we call fetch and return the results
		@results = get_results(@query, @categories, @sources)
		respond_with(@results)
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
			user = current_user.id if user_signed_in? else -1
			@suggestions = Search.suggest(@query, page, long, lat, loc, user)
		end
		respond_with(@suggestions)
	end
	
	def fetch
		@query = query_param
		respond_with({ error: 'query cannot be empty' }) if @query.blank?
		@results = get_results(@query, category_param, source_param)
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
			s.sources = source_param
			s.page = request.referer || ""
			s.user = current_user if user_signed_in?
			s.save
		rescue
			logger.error "could not save search for #{query_param}"
		end
	end
	
	def get_results(query, categories, sources)
		
		hits = []
		if Search.latest_search(query, categories, sources) > 1.week.ago
			hits.concat(parse(Backend::Lastfm.search(query, categories))) if sources.include? 'lastfm'
			hits.concat(parse(Backend::Youtube.search(query, categories))) if sources.include? 'youtube'
			#hits.concat(parse(Backend::Soundcloud.search(query, categories))) if sources.include? 'soundcloud'
			#hits.concat(parse(Backend::Jamendo.search(query, categories))) if sources.include? 'jamendo'
			save_hits(hits)
		else
			hits = search_in_db(query, categories, sources)
		end
		
		hits = rank(hits, query)
		
		# turns hits into an array of objects
		
		results = { hits: hits.collect { |h|
			h.except(:distance, :score)
		} }
		results[:exact] = {}
		
		results[:hits].each do |h|
			next if h[:name].downcase != query.downcase
			results[:exact][h[:type]] ||= h
		end
		
		results
	end
	
	def rank(hits, query)
		# some hits have no popularity, so we try to fix that
		#fill_nil_popularity(hits)
		
		hits.each do |h|
			h[:distance] = distance(query, h[:fullname])
			h[:score] = h[:distance] * WEIGHT_SIMILARITY + h[:popularity] * WEIGHT_POPULARITY
		end
		
		hits = hits.sort_by { |h| h[:score] }.reverse
	end
	
	def parse(hits)
		# parse hits (extract artists and song titles, for example) and
		# put into a structure, separated by type
		parsed_hits = parse_hits(hits)
		
		# flatten structure into an array
		parsed_hits = parsed_hits.collect { |k,v| v.values }.flatten
			
		# turn absolute popularity into relative popularity
		normalize_popularity(parsed_hits)
		
		return parsed_hits
	end
	
	def parse_hits(hits)
		parsed_hits = { artist: {}, song: {}, album: {}, event: {}, genre: {}}
		hits.each do |hit|
			begin
				hit[:fullname] ||= hit[:name]
				case hit[:type]
				when :artist then
				
					# some artists are named "Foo feat. Bar" so we split
					# the name and divide the popularity among them
					artists = Artist.split_name(hit[:name])
					popularity_pot = hit[:popularity] / artists.count.to_f
					artists.each do |name|
						h = hit.dup
						h[:popularity] = popularity_pot
						h[:name] = name
						add_parsed_hit(:artist, parsed_hits, h)
					end
				
				when :song then
					# songs usually contain the name of the artist in their title
					# so we do our best to extract the artist and the name of the
					# song from the song title 
					artist,title = Song.parse_title(hit[:name])
					hit[:name] = title
					hit[:artist] ||= artist
					hit[:artists] = Artist.split_name(hit[:artist]) if hit[:artist]
					add_parsed_hit(:song, parsed_hits, hit, true)
					
				when :album
					hit[:artists] = Artist.split_name(hit[:artist]) if hit[:artist]
					add_parsed_hit(:album, parsed_hits, hit, true)
				
				else
					add_parsed_hit(:album, parsed_hits, hit, true)
				end
			rescue
			end
		end
		return parsed_hits
	end
	
	def save_hits(hits)
		retval = []
		hits.each do |hit|
			begin
				x = nil
				case hit[:type]
				when :song
					x = Song.get(hit)
				when :artist
					x = Artist.get(hit)
				when :album
					x = Album.get(hit)
				when :event
					x = Event.get(hit)
				#when :genre
				#	x = Genre.get(hit)
				else
					raise "Unknown hit type: #{hit[:type]}"
				end
				retval << x if x
			rescue
			end
		end
		return retval
	end
	
	def fill_nil_popularity(hits)
		artists = hits.collect { |h| h[:type] == :artist }
		hits.each do |h|
			next unless h[:popularity] == nil
			case h[:type]
			when :song, :album
				next unless h[:artists]
				h[:artists].each do |a|
					if artists.has_key? a
						h[:popularity] += artists[a][:popularity].to_f
					end
				end
			end
		end
	end
	
	def normalize_popularity(hits)
		pop = hits.select { |x| x[:popularity] != nil }.collect { |x| x[:popularity] }
		avg_popularity = 0
		max_popularity = 0
		if pop.length > 0
			avg_popularity = pop.inject(0) { |s,x| s+= x } / pop.length
			max_popularity = pop.max
		end
		max_popularity = 1 if max_popularity == 0
		hits.collect do |x|
			if x[:popularity] == nil
				x[:popularity] = avg_popularity
			end
			#else
			x[:popularity] /= max_popularity
			#end
		end
		hits
	end
	
	def add_parsed_hit(type, collection, hit, allow_dups = false)
		# duplicates: random key, otherwise use name
		key = allow_dups ? (0...16).map { (65 + rand(26)).chr }.join : hit[:name].downcase
		
		if collection[type].has_key? key
			collection[type][key][:popularity] += hit[:popularity]
		else
			collection[type][key] = hit
		end
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
