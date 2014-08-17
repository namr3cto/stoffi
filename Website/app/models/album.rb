# -*- encoding : utf-8 -*-
# The model of the album resource.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2013 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

require 'base'

# Describes an album, created by one or more artists, containing songs.
class Album < ActiveRecord::Base
	include Base
	
	# associations
	with_options uniq: true do |assoc|
		assoc.has_and_belongs_to_many :artists
		assoc.has_and_belongs_to_many :songs
	end
	
	with_options as: :resource, dependent: :destroy do |assoc|
		assoc.has_many :sources
		assoc.has_many :images
	end
	
	validates :title, presence: true
	
	searchable do
		text :title, boost: 5
		text :artists do
			artists.map(&:name)
		end
	end
	
	# The string to display to users for representing the resource.
	def display
		title
	end
	
	def self.find_or_create_by_hash(hash)
		validate_hash(hash)
		album = find_by_hash(hash)
		album = create_by_hash(hash) unless album
		
		source = Source.find_or_create_by_hash(hash)
		album.sources << source if source and not album.sources.include? source
		
		if hash.key? :images
			images = Image.create_by_hashes(hash[:images])
			album.images << images
		end
			
		logger.debug hash.inspect
		if hash.key? :songs
			hash[:songs].each do |song|
				song = Song.get(nil, song)
				album.songs << song if song
			end
		end
		
		return album
	end
	
	def self.find_by_hash(hash)
		validate_hash(hash)
		anum = 1
		astr = hash[:artist]
		if hash.key? :artists
			anum = hash[:artists].length
			astr = hash[:artists].join(',')
		end
		
		where(title: hash[:name]).each do |a|
			next unless a.artists.length == anum
			return a if a.artists.collect{|x|x.name}.join(',') == astr
		end
		return nil
	end
	
	def self.create_by_hash(hash)
		validate_hash(hash)
		begin
			album = create(
				title: hash[:name],
				year: hash[:year]
			)
			
			artists = hash[:artists]
			artists = [hash[:artist]] unless artists
			artists.each do |artist|
				artist = Artist.find_or_create_by(name: artist)
				album.artists << artist if artist
			end
			
			return album
			
		rescue StandardError => e
			raise e
		end
	end
	
	# Returns an album matching a value.
	#
	# The value can be the ID (integer) or the name (string) of the artist.
	# The artist will be created if it is not found (unless <tt>value</tt> is an ID).
	def self.get(value)
		value = find(value) if value.is_a?(Integer)
		value = find_or_create_by(title: value) if value.is_a?(String)
		return value if value.is_a?(Playlist)
		return nil
	end
	
	# Paginates the songs of the album. Should be called before <tt>paginated_songs</tt> is called.
	#
	#   album.paginate_songs(10, 30)
	#   songs = album.paginated_songs # songs will now hold the songs 30-39 (starting from 0)
	def paginate_songs(limit, offset)
		@paginated_songs = Array.new
		songs.limit(limit).offset(offset).each do |song|
			@paginated_songs << song
		end
	end
	
	# Returns a slice of the album's songs which was created by <tt>paginated_songs</tt>.
	#
	#   album.paginate_songs(10, 30)
	#   songs = album.paginated_songs # songs will now hold the songs 30-39 (starting from 0)
	def paginated_songs
		return @paginated_songs
	end
	
	private
	
	def self.validate_hash(hash)
		raise "Missing name in hash" unless hash.key? :name
		raise "Missing artists in hash" unless hash.key?(:artists) or hash.key?(:artist)
	end
	
end
