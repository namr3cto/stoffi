# -*- encoding : utf-8 -*-
# The di.fm backend for the content engine.
#
# Provides access to ... TODO
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2014 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

module Backend::DigitallyImported
	extend ActiveSupport::Concern
	
	# Search for a query in a given set of categories
	def self.search(query, categories)
	end
	
	private
	
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