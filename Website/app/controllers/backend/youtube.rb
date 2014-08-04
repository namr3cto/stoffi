# -*- encoding : utf-8 -*-
# The YouTube backend for the content engine.
#
# Provides acess to music videos.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2014 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

module Backend::Youtube
	extend ActiveSupport::Concern
	
	SEARCH_PARTS = "id"
	SEARCH_FIELDS = "items(id/videoId)"
	DETAILS_PARTS = "snippet,statistics"
	DETAILS_FIELDS = "items(snippet(title,thumbnails),statistics/viewCount)"
	
	# Search for a query in a given set of categories
	def self.search(query, categories)
		return [] unless categories.include? 'songs'
		response = req("search?type=video&part=#{SEARCH_PARTS}&fields=#{SEARCH_FIELDS}&q=#{query}&maxResults=20")
		Rails.logger.debug response.inspect
		ids = response['items'].collect { |i| i['id']['videoId'] }.join(',')
		Rails.logger.debug ids.inspect
		response = req("videos?part=#{DETAILS_PARTS}&fields=#{DETAILS_FIELDS}&id=#{ids}")
		items = []
		response['items'].each do |i|
			item = {
				name: i['snippet']['title'],
				popularity: i['statistics']['viewCount'].to_f,
				images: {},
				type: :song
			}
			i['snippet']['thumbnails'].keys.each do |t|
				u = i['snippet']['thumbnails'][t]['url']
				s = case t
				when 'default' then :tiny
				when 'medium' then :small
				when 'high' then :medium
				when 'standard' then :large
				when 'maxres' then :huge
				else :unknown
				end
				item[:images][s] = u
			end
			items << item
		end
		Rails.logger.debug items.inspect
		return items
	end
	
	private
	
	# Make a request to the API
	def self.req(query)
		begin
			query = URI.escape(query)
			url = "#{creds['url']}/#{query}&key=#{creds['key']}"
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
		Rails.application.secrets.oa_cred['youtube']
	end
end