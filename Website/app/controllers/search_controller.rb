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
		save_search if @query.present?
		@title = e(params[:q])
		@description = t("index.description")
		
		render and return if request.format == :html
			
		# request is API call, so we call fetch and return the results
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
			user = user_signed_in? ? current_user.id : -1
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
	
	def get_results(query, categories, sources)
		
		hits = []
		if Search.latest_search(query, categories, sources) < 1.week.ago
			hits.concat(parse(Backend::Lastfm.search(query, categories))) if sources.include? 'lastfm'
			hits.concat(parse(Backend::Youtube.search(query, categories))) if sources.include? 'youtube'
			#hits.concat(parse(Backend::Soundcloud.search(query, categories))) if sources.include? 'soundcloud'
			#hits.concat(parse(Backend::Jamendo.search(query, categories))) if sources.include? 'jamendo'
			hits = save_hits(hits)
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
			next if h[:object].display.downcase != query.downcase
			results[:exact][h[:object].class.to_s.underscore.to_sym] ||= h
		end
		
		results
	end
	
	# Rank an array of hits according to a query, putting the most
	# relevant hit at the start of the array
	def rank(hits, query)
		hits = fill_meta(hits)
		
		hits.each do |h|
			h[:distance] = distance(query, h[:object].display)
			h[:score] = h[:distance] * WEIGHT_SIMILARITY + 
			            h[:popularity] * WEIGHT_POPULARITY
		end
		
		hits = hits.sort_by { |h| -1 * h[:score] }
	end
	
	# Parse an array of hits, as reported by backends, into an array
	# where artists has been parsed and split if needed, song titles
	# have been parsed and split into song title and artist name, and
	# popularity has been normalized.
	def parse(hits)
		# parse hits (extract artists and song titles, for example) and
		# put into a structure, separated by type
		parsed_hits = parse_hits(hits)
		
		# flatten structure into an array
		parsed_hits = parsed_hits.collect { |k,v| v.values }.flatten
		
		return parsed_hits
	end
	
	# Parse an array of hits, as reported by backends, into a hash
	# of results where hits separated by type and some values are
	# parsed (such as song titles and artist names)
	def parse_hits(hits)
		parsed_hits = { artist: {}, song: {}, album: {}, event: {}, genre: {}}
		hits.each do |hit|
			begin
				hit[:fullname] ||= hit[:name]
				case hit[:object]
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
	
	def search_in_db(query, categories, sources)
		retval = []
		if 'artists'.in? categories
			retval += Artist.search {
				keywords(query, minimum_matches: 1)
			}.results
		end
		if 'albums'.in? categories
			retval += Album.search {
				keywords(query, minimum_matches: 1)
			}.results
		end
		if 'events'.in? categories
			retval += Event.search {
				keywords(query, minimum_matches: 1)
			}.results
		end
		if 'songs'.in? categories
			retval += Song.search {
				keywords(query, minimum_matches: 1)
				with(:locations, sources)
			}.results
		end
		logger.debug retval.inspect
		return retval
	end
	
	# Save a hash of hits to the database.
	#
	# The saved objects should function as full replacements of the
	# actual hits, which allows us to use the database as a cache,
	# minimizing the need to send queries to the backends.
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
					x = Album.find_or_create_by_hash(hit)
				when :event
					x = Event.find_or_create_by_hash(hit)
				#when :genre
				#	x = Genre.get(hit)
				else
					raise "Unknown hit type: #{hit[:type]}"
				end
				
				retval << x if x
				
			rescue StandardError => e
				raise e
			end
		end
		return retval
	end
	
	# Save a search
	#
	# This is later used for auto-complete suggestions, and
	# for knowing when a cache is dirty
	def save_search
		begin
			logger.debug "saving query #{query_param}"
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
		rescue
			logger.error "could not save search for #{query_param}"
		end
	end
	
	# Fill in meta data for objects such as popularity
	def fill_meta(hits)
		sources = hits.collect { |h| h.sources.to_a }.flatten
		popularity = {}
		sources.each do |s|
			popularity[s.resource_type] = {} unless popularity.key? s.resource_type
			if popularity[s.resource_type].key? s.name
				popularity[s.resource_type][s.name][:max] += s.popularity
				popularity[s.resource_type][s.name][:len] += 1
			else
				popularity[s.resource_type][s.name] = { max: s.popularity, len: 1 }
			end
		end
		popularity.each do |k,v|
			popularity[k][:avg] = (v[:max] || 0) / (v[:len] || 1)
		end
		
		retval = []
		hits.each do |h|
			o = { object: h, popularity: 0 }
			h.sources.each do |s|
				p = popularity[s.resource_type][s.name]
				o[:popularity] = (s.popularity || p[:avg]) / (p[:max] || 1)
			end
			retval << o
		end
		return retval
	end
	
	# Add a hit, as reported from a backend, into a hash of hits
	# where the key is either the name (allow_dups = false) or a
	# random string
	def add_parsed_hit(type, collection, hit, allow_dups = false)
		# duplicates: random key, otherwise use name
		key = allow_dups ? (0...16).map {(65+rand(26)).chr}.join : hit[:name].downcase
		
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
