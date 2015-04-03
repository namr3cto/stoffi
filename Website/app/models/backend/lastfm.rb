# -*- encoding : utf-8 -*-
# The Last.fm backend for the content engine.
#
# Allows for searching and retrieving information (including images) on
# artists, albums, songs and events.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2014 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

class Backend::Lastfm
	
	# Search for a query in a given set of categories
	def self.search(query, categories)
		hits = { 'artists' => [], 'albums' => [], 'songs' => [], 'events' => [] }
		threads = []
		
		hits.each do |k,v|
			if categories.include? k
				threads << Thread.new { v.concat search_for(category_to_resource(k),query) }
			end
		end
		threads.each { |t| t.join }
		
		return hits.inject([]) { |a,(k,v)| a.concat v }
	end
	
	def self.get_songs(ids)
		ids.each do |id|
		end
	end
	
	def self.get_info(name, category)
		resource = category_to_resource(category)
		hit = nil
		case resource
		when 'artist', 'event'
			hit = get_resource_info(resource, "#{resource}=#{name}")
		else
			parts = name.split("\t")
			raise "Need to specify artist" if parts.length < 2
			name = parts[0]
			artist = parts[1]
			query = "artist=#{artist}&#{resource}=#{name}"
			hit = get_resource_info(resource, query)
		end
		return parse_hit(hit, resource)
	end
	
	private
	
	# Turn a category into a resource
	def self.category_to_resource(category)
		category = category.singularize
		return 'track' if category == 'song'
		return category
	end
	
	# Turn a resource into a type
	def self.resource_to_type(resource)
		case resource
		when 'track' then :song
		else resource.to_sym
		end
	end
	
	# Search for a given resource
	def self.search_for(resource, query)
		hits = []
		begin
			get_hits(resource, query) do |h|
				begin
					hit = parse_hit(h, resource)
					hits << hit if hit
					
				rescue StandardError => e
					Rails.logger.error "error parsing hit #{h.inspect}: #{e.message}"
				end
			end
		rescue StandardError => e
			Rails.logger.error "error searching for resource #{resource}: #{e.message}"
		end
		hits
	end
	
	def self.parse_hit(hit, resource)
		return nil unless hit
		retval = {
			type: resource_to_type(resource),
			images: [],
			source: :lastfm,
			url: hit['url'],
		}
		case resource
		when 'artist' then
			retval[:popularity] = hit['listeners'].to_f
			retval[:name] = hit['name']
			retval[:id] = hit['name']
		
		when 'album' then
			retval[:name] = hit['name']
			retval[:artist] = hit['artist']
			retval[:fullname] = "#{hit['name']} by #{hit['artist']}"
			retval[:id] = "#{retval[:name]}\t#{retval[:artist]}"
			
		when 'track' then
			retval[:popularity] = hit['listeners'].to_f
			retval[:name] = hit['name']
			retval[:artist] = hit['artist']
			retval[:id] = "#{retval[:name]}\t#{retval[:artist]}"
			
		when 'event' then
			retval[:popularity] = hit['attendance'].to_f
			retval[:name] = hit['title']
			a = hit['artists']['artist']
			a = [a] unless a.is_a? Array
			retval[:artists] = a
			retval[:fullname] = "#{retval[:artists].join(', ')} @ #{retval[:name]}"
			geopoint = hit['venue']['location']['geo:point']
			long = geopoint['geo:long'].to_f
			lat = geopoint['geo:lat'].to_f
			retval[:location] = { longitude: long, latitude: lat }
			retval[:city] = hit['venue']['location']['city']
			retval[:id] = hit['id']
			retval[:start_date] = hit['startDate']
			retval[:end_date] = hit['endDate']
			
		else
			return nil
		end
					
		if hit['image']
			hit['image'].each do |i|
				retval[:images] << { url: i['#text'] }
			end
		end
		
		return retval
	end
	
	# Extract the array of hits from a search response
	def self.get_resource_info(resource, query)
		begin
			response = req("method=#{resource}.getInfo&#{query}")
			return response[resource] if response[resource]
		rescue StandardError => e
			Rails.logger.debug response.inspect
			Rails.logger.error "error getting hits for resource #{resource}: #{e.message}"
		end
	end
	
	# Extract the array of hits from a search response
	def self.get_hits(resource, query)
		begin
			response = req("method=#{resource}.search&#{resource}=#{query}")
			return if response['results']['opensearch:totalResults'] == '0'
			hits = response['results']["#{resource}matches"][resource]
			hits.each { |h| yield h }
		rescue StandardError => e
			Rails.logger.debug response.inspect
			Rails.logger.error "error getting hits for resource #{resource}: #{e.message}"
		end
	end
	
	# Make a request to the API
	def self.req(query)
		begin
			query = URI.escape(query)
			url = "#{creds['url']}/2.0?#{query}&format=json&api_key=#{creds['id']}"
			url = URI.parse(url)
			http = Net::HTTP.new(url.host, url.port)
			http.use_ssl = (url.scheme == 'https')
			Rails.logger.debug "fetching: #{url}"
			data = http.get(url.request_uri)
			feed = JSON.parse(data.body)
			return feed
		rescue StandardError => e
			Rails.logger.error "error making request: #{e.message}"
		end
	end
	
	# The API credentials
	def self.creds
		Rails.application.secrets.oa_cred['lastfm']
	end
end