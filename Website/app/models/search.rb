class Search < ActiveRecord::Base
	belongs_to :user
	
	def self.suggest(query, page, longitude, latitude, locale, user_id = -1, limit = 10)
		terms = []
		self.select("*, count(*) as hits").where("lower(query) like ?", [query.downcase+'%']).
		     group("lower(query)").order("hits desc").find_each do |search|
			logger.debug search.inspect
			weight = 1.0
			debug = {}
			
			if search.page == page
				weight *= SCORE_WEIGHT_PAGE
			end
			
			if search.locale == locale
				weight *= SCORE_WEIGHT_LOCALE
			end
			
			if search.user_id.to_i > 0 and user_id.to_i > 0 and search.user_id == user_id
				weight *= SCORE_WEIGHT_USER
			end
			
			longitude ||= 0
			latitude ||= 0
			
			d = Haversine.distance(
				longitude, latitude, search.longitude, search.latitude).to_meters / 10000
			d = 0.001 if d == 0
			weight *= eval(SCORE_WEIGHT_DISTANCE.sub('x', d.to_s)).to_f
			
			terms << {query: search.query, score: search.hits.to_f * weight.to_f}
			x = {query: search.query, score: search.hits.to_f * weight.to_f}
			logger.debug x.inspect
		end
		return terms.sort_by { |x| x[:score] }.reverse[0..limit-1]
	end
	
	def do
		results = {}
		time = Benchmark.measure do
			hits = []
			if previous_at < CACHE_EXPIRATION.ago
				logger.info "fill db from backends"
				hits += Backend::Lastfm.search(query, categories) if sources.include? 'lastfm'
				hits += Backend::Youtube.search(query, categories) if sources.include? 'youtube'
				hits = parse(hits)
				hits = save_hits(hits)
			end
			hits = search_in_db(query, categories, sources)
			hits = rank(hits, query)
		
			results = { hits: hits.collect { |h|
				h.except(:distance, :score)
			} }
			results[:exact] = {}
		
			results[:hits].each do |h|
				next if h[:object].display.downcase != query.downcase
				results[:exact][h[:object].class.to_s.underscore.to_sym] ||= h
			end
		end
		results[:benchmark] = time
		results
	end
	
	def previous_at
		begin
			s = Search.where(query: query, categories: categories, sources: sources)
				.order(updated_at: :desc).offset(1).limit(1)
			return s.first.updated_at if s and s.first
		rescue StandardError => e
		end
		(updated_at - CACHE_EXPIRATION - 1.second)
	end
	
	def categories_array
		categories.to_s.split('|').sort
	end
	
	def sources_array
		sources.to_s.split('|').sort
	end
	
	private
	
	# The time a search is cached to ease pressure on backends
	CACHE_EXPIRATION = 1.week
	
	# These weights are used for ranking search results.
	# score = similarity * w_s + popularity * w_n
	HIT_WEIGHT_SIMILARITY = 5 # w_s
	HIT_WEIGHT_POPULARITY = 3 # w_p
	
	# These weight are used for ranking search suggestions.
	# score = h * w_1 * w_2 * w_3 ... * w_d
	# where w_n is the weight for a certain condition
	# and w_d is explained below
	
	# Condition: performed on same page
	SCORE_WEIGHT_PAGE = 2.5
	
	# Condition: performed under same locale
	SCORE_WEIGHT_LOCALE = 3 # w_l
	
	# Condition: part of the current user's search history
	SCORE_WEIGHT_USER = 10 # w_u
	
	# This is w_d, it is evaluated where x is the distance in 10 km
	SCORE_WEIGHT_DISTANCE = '[5, 10.0/x].min' # w_d
	
	# Rank an array of hits according to a query, putting the most
	# relevant hit at the start of the array
	def rank(hits, query)
		hits = fill_meta(hits)
		
		hits.each do |h|
			h[:distance] = distance(query, h[:object].display)
			h[:score] = h[:distance] * HIT_WEIGHT_SIMILARITY + 
			            h[:popularity] * HIT_WEIGHT_POPULARITY
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
				case hit[:type]
				when :artist then
					
					# some artists are named "Foo feat. Bar" so we split
					# the name and divide the popularity among them
					artists = Artist.split_name(hit[:name])
					logger.debug "Artist.split_name('#{hit[:name]}')"
					logger.debug artists.inspect
					popularity_pot = hit[:popularity] / artists.count.to_f
					artists.each do |name|
						h = hit.dup
						h[:popularity] = popularity_pot
						h[:name] = name
						logger.debug 'add partial name: '+name
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
		return retval.uniq
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
					x = Song.get(nil, hit, false)
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
	
	# Fill in meta data for objects such as popularity
	def fill_meta(hits)
		sources = hits.collect { |h| h.sources.to_a }.flatten
		popularity = {}
		sources.each do |s|
			popularity[s.resource_type] = {} unless popularity.key? s.resource_type
			if popularity[s.resource_type].key? s.name
				popularity[s.resource_type][s.name][:max] += (s.popularity || 0)
				popularity[s.resource_type][s.name][:len] += 1
			else
				popularity[s.resource_type][s.name] = { max: (s.popularity || 0), len: 1 }
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
				d = p[:max].to_i == 0 ? 1 : p[:max].to_i
				o[:popularity] = (s.popularity || p[:avg].to_i) / d
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
		key = allow_dups ? (0...16).map {(65+rand(26)).chr}.join : hit[:name].parameterize('_')
		
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
