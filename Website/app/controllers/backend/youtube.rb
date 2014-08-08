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
	DETAILS_PARTS = "snippet,statistics,contentDetails"
	DETAILS_FIELDS = "items(snippet(title,thumbnails),statistics/viewCount,contentDetails/duration)"
	
	# Search for a query in a given set of categories
	def self.search(query, categories)
		return [] unless categories.include? 'songs'
		
		path  = 'search?type=video&maxResults=20&videoCategoryId=10'
		path += '&videoEmbeddable=true'
		path += "&part=#{SEARCH_PARTS}&fields=#{SEARCH_FIELDS}"
		path += "&q=#{query}"
		response = req(path)
		ids = response['items'].collect { |i| i['id']['videoId'] }
		
		return get_songs(ids)
	end
	
	def self.get_songs(ids)
		songs = []
		
		begin
			ids = ids.join(',')
			path  = 'videos'
			path += "?part=#{DETAILS_PARTS}&fields=#{DETAILS_FIELDS}"
			path += "&id=#{ids}"
			response = req(path)
			items = []
			response['items'].each do |i|
				begin
					id = i['id']
					begin
						dur = Duration.new(i['contentDetails']).total.to_f
					rescue
						dur = 0.0
					end
					song = {
						name: i['snippet']['title'],
						url: "https://www.youtube.com/watch?v=#{id}",
						popularity: i['statistics']['viewCount'].to_f,
						length: dur,
						path: 'stoffi:track:youtube:'+id,
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
						song[:images][s] = u
					end
					songs << song
				rescue StandardError => e
					raise e
					logger.error "error parsing youtube json video: #{e.message}"
				end
			end
		
		rescue StandardError => e
			raise e
			logger.error "error retrieving youtube videos: #{e.message}"
		end
		
		return songs
	end
	
	private
	
	# Make a request to the API
	def self.req(query)
		begin
			query = URI.escape(query)
			url = "#{creds['url']}/#{query}"
			url = URI.parse(url)
			url.query = [url.query, "key=#{creds['key']}"].compact.join('&')
			http = Net::HTTP.new(url.host, url.port)
			http.use_ssl = (url.scheme == 'https')
			Rails.logger.debug "fetching: #{url}"
			data = http.get(url.request_uri)
			feed = JSON.parse(data.body)
			return feed
		rescue StandardError => e
			raise e
			Rails.logger.error "error making request: #{e.message}"
		end
	end
	
	# The API credentials
	def self.creds
		Rails.application.secrets.oa_cred['youtube']
	end
end