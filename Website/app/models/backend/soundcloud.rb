# -*- encoding : utf-8 -*-
# The SoundCloud backend for the content engine.
#
# Provides access to songs.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2014 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

class Backend::Soundcloud
	extend ActiveSupport::Concern
	
	def self.search(query, categories)
		songs = []
		return songs unless categories.include? 'songs'
		begin
			tracks = req("tracks.json?q=#{query}")
			tracks.each do |track|
				begin
					song = parse_track(track)
					songs << song if song
				rescue StandardError => e
					Rails.logger.error "error parsing track: #{e.message}"
					raise e
				end
			end
		rescue StandardError => e
			Rails.logger.error "error searching soundcloud: #{e.message}"
			raise e
		end
		return songs
	end
	
	def self.get_songs(ids)
		songs = []
		ids.each do |id|
			begin
				track = req("tracks/#{id}.json")
				songs << parse_track(track)
			rescue StandardError => e
				Rails.logger.error "error parsing soundcloud json track: #{e.message}"
			end
		end
		return songs
	end
	
	private
	
	def self.parse_track(track)
		song = {
			name: track['title'],
			url: track['permalink_url'],
			popularity: track['playback_count'].to_f,
			length: track['duration'].to_f / 1000.0,
			images: [],
			user: track['user']['username'],
			stream: track['stream_url'],
			path: 'stoffi:track:soundcloud:'+track['id'].to_s,
			type: :song,
			source: :youtube,
		}
		if track['artwork_url']
			song[:images] << {
				url: track['artwork_url'],
				width: 100,
				height: 100
			}
		end
		return song
	end
	
	def self.req(query)
		begin
			query = URI.escape(query)
			url = "#{creds['url']}/#{query}"
			url = URI.parse(url)
			url.query = [url.query, "client_id=#{creds['id']}"].compact.join('&')
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
			
		http = Net::HTTP.new("api.soundcloud.com", 443)
		http.use_ssl = true
		data = http.get("/tracks/#{song.soundcloud_id}.json?client_id=#{client_id}", {})
		track = JSON.parse(data.body)
	end
	
	# The API credentials
	def self.creds
		Rails.application.secrets.oa_cred['soundcloud']
	end
end