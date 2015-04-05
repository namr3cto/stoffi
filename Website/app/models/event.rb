# -*- encoding : utf-8 -*-
# The model of the event resource.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2014 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

require 'base'

# Describes an event where artists have performances
class Event < ActiveRecord::Base
	include Base
	include Imageable
	include Sourceable
	include Rankable
	include Duplicatable
	
	has_and_belongs_to_many :artists, join_table: :performances
	has_many :listens, through: :artists
	
	validates :name, :venue, :start, :longitude, :latitude, presence: true
	validates :longitude, :latitude, numericality: true
	validates :name, uniqueness: { scope: [ :start, :venue ] }
	
	acts_as_mappable lat_column_name: :latitude, lng_column_name: :longitude
	
	self.default_image = "gfx/icons/256/event.png"
	
	searchable do
		text :name, boost: 5
		text :content, :category
		string :locations, multiple: true do
			sources.map(&:name)
		end
	end
	
	def self.find_or_create_by_hash(hash)
		validate_hash(hash)
		event = find_by_hash(hash)
		event = create_by_hash(hash) unless event
		
		source = Source.find_or_create_by_hash(hash)
		event.sources << source if source and not event.sources.include? source
		
		if hash.key? :images
			images = Image.create_by_hashes(hash[:images])
			event.images << images
		end
		
		return event
	end
	
	def self.find_by_hash(hash)
		validate_hash(hash)
		
		# look for same name, same city and same start date (within an hour)
		date = hash[:start_date]
		date = Date.parse(date) if date.is_a? String
		date = Time.now unless date
		d_upper = date + 1.hour
		d_lower = date - 1.hour
		event = where("lower(name) = ? and lower(venue) = ? and start between ? and ?",
			hash[:name].to_s.downcase, hash[:city].to_s.downcase, d_lower, d_upper).first
		return event if event
		
		# look for same source
		source = Source.find_by_hash(hash)
		return source.resource if source
		return nil
	end
	
	def self.create_by_hash(hash)
		validate_hash(hash)
		begin
			event = create(
				name: hash[:name],
				venue: hash[:city],
				start: hash[:start_date],
				stop: hash[:end_date],
				category: hash[:category],
			)
			
			if hash.key? :location
				event.longitude = hash[:location][:longitude]
				event.latitude = hash[:location][:latitude]
				event.save
			end
			
			if hash.key? :artists
				hash[:artists].each do |artist|
					artist = Artist.find_or_create_by(name: artist)
					event.artists << artist if artist
				end
			end
			return event
		rescue StandardError => e
		end
	end
	
	def self.upcoming
		where(['start > ?', Time.now])
	end
	
	def display
		name
	end
	
	private
	
	def self.validate_hash(hash)
		raise "Missing name in hash" unless hash.key? :name
		raise "Missing city in hash" unless hash.key? :city
		raise "Missing start date in hash" unless hash.key? :start_date
	end
end
