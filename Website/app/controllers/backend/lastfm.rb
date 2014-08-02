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

module Backend::Lastfm
	extend ActiveSupport::Concern
	
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
	
	private
	
	# Turn a category into a resource
	def self.category_to_resource(category)
		case category
		when 'artists' then 'artist'
		when 'albums' then 'album'
		when 'songs' then 'track'
		when 'events' then 'event'
		end
	end
	
	# Search for a given resource
	def self.search_for(resource, query)
		hits = []
		begin
			get_hits(resource, query) do |h|
				begin
					hit = { type: resource}
					case resource
					when 'artist' then
						hit[:popularity] = h['listeners']
						hit[:name] = h['name']
					
					when 'album' then
						hit[:name] = h['name']
						
					when 'track' then
						hit[:popularity] = h['listeners']
						hit[:name] = h['name']
						
					when 'event' then
						hit[:popularity] = h['attendance']
						hit[:name] = h['title']
						
					else
						hit = nil
					end
					
					hits << hit if hit
					
				rescue Exception => e
					Rails.logger.error "error parsing hit #{h.inspect}: #{e.message}"
				end
			end
		rescue Exception => e
			Rails.logger.error "error searching for resource #{resource}: #{e.message}"
		end
		hits
	end
	
	# Extract the array of hits from a search response
	def self.get_hits(resource, query)
		begin
			response = req("method=#{resource}.search&#{resource}=#{query}")
			hits = response['results']["#{resource}matches"][resource]
			hits.each { |h| yield h }
		rescue Exception => e
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
		rescue Exception => e
			Rails.logger.error "error making request: #{e.message}"
		end
	end
	
	# The API credentials
	def self.creds
		Rails.application.secrets.oa_cred['lastfm']
	end
end