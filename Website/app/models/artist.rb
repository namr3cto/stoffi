# -*- encoding : utf-8 -*-
# The model of the artist resource.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2013 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

require 'base'

# Describes an artist in the database.
class Artist < ActiveRecord::Base
	include Base
	include Imageable
	include Sourceable
	include Rankable
	include Duplicatable
	
	# associations
	with_options uniq: true do |assoc|
		assoc.has_and_belongs_to_many :albums
		assoc.has_and_belongs_to_many :songs
		assoc.has_and_belongs_to_many :events, join_table: :performances
	end
	has_many :genres, through: :songs
	has_many :listens, through: :songs
	has_many :donations
	
	# validations
	validates_uniqueness_of :name
	validates_presence_of :name
	
	include_associations_of_dups :listens
	
	searchable do
		text :name
		string :locations, multiple: true do
			sources.map(&:name)
		end
	end
	
	self.default_image = "gfx/icons/256/artist.png"
	
	# Whether or not the artist has a Twitter account.
	def twitter?; twitter.present? end
	# Whether or not the artist has a Facebook page or account.
	def facebook?; facebook.present? end
	# Whether or not the artist has a Google+ account.
	def googleplus?; googleplus.present? end
	# Whether or not the artist has a MySpace account.
	def myspace?; myspace.present? end
	# Whether or not the artist has a YouTube channel or account.
	def youtube?; youtube.present? end
	# Whether or not the artist has a SoundCloud account.
	def soundcloud?; soundcloud.present? end
	# Whether or not the artist has a Spotify presence.
	def spotify?; spotify.present? end
	# Whether or not the artist has a Last.fm presence.
	def lastfm?; lastfm.present? end
	# Whether or not the artist has a website.
	def website?; website.present? end
	
	# The URL to the artist's Twitter account.
	def twitter_url; "https://twitter.com/#{twitter}" end
	# The URL to the artist's Facebook page or account.
	def facebook_url; "https://facebook.com/#{facebook}" end
	# The URL to the artist's Google+ account.
	def googleplus_url; "https://plus.google.com/#{googleplus}" end
	# The URL to the artist's MySpace account.
	def myspace_url; "https://myspace.com/#{myspace}" end
	# The URL to the artist's YouTube channel or account.
	def youtube_url; "https://youtube.com/user/#{youtube}" end
	# The URL to the artist's SoundCloud account.
	def soundcloud_url; "https://soundcloud.com/#{soundcloud}" end
	# The URL to the artist's Spotify page.
	def spotify_url; "http://open.spotify.com/artist/#{spotify}" end
	# The URL to the artist's Last.fm page.
	def lastfm_url; "https://last.fm/music/#{lastfm}" end
	# The URL to the artist's website.
	def website_url; website end
	
	# Whether or not the artist has any links to external properties.
	def any_places?
		twitter? or facebook? or googleplus? or myspace? or
		youtube? or soundcloud? or spotify? or lastfm? or website?
	end
	
	# The URL for the streaming of the artist.
	# NOT IMPLEMENTED YET
	def stream_url
		"http://www.google.com"
	end
	
	# Whether the artist is unknown.
	def unknown?
		return name.blank?
	end
	
	# The string to display to users for representing the resource.
	def display
		name
	end
	
	# All donations which are either pending of successful.
	def donated
		donations.where("status != 'returned' AND status != 'failed' AND status != 'revoked'")
	end
	
	# The amount of charity that donations to the artist has generated.
	def charity_sum
		donated.sum("amount * (charity_percentage / 100)").to_f.round(2)
	end
	
	# The amount that has been donated to the artist (including pending donations).
	def donated_sum
		donated.sum("amount * (artist_percentage / 100)").to_f.round(2)
	end
	
	# All pending donations to the artist.
	def pending
		donations.where("donations.status = 'pending' AND created_at < ?", Donation.revoke_time)
	end
	
	# The amount that has been donated to the artist but not yet processed.
	def pending_sum
		pending.sum("amount * (artist_percentage / 100)").to_f.round(2)
	end
	
	# Whether or not it's not possible to send any donations to the artist.
	def undonatable
		unknown? || donatable_status.blank?
	end
	
	# Paginates the songs of the artist. Should be called before <tt>paginated_songs</tt> is called.
	#
	#   artist.paginate_songs(10, 30)
	#   songs = artist.paginated_songs # songs will now hold the songs 30-39 (starting from 0)
	def paginate_songs(limit, offset)
		@paginated_songs = Array.new
		songs.limit(limit).offset(offset).each do |song|
			@paginated_songs << song
		end
	end
	
	# Returns a slice of the artist's songs which was created by <tt>paginated_songs</tt>.
	#
	#   artist.paginate_songs(10, 30)
	#   songs = artist.paginated_songs # songs will now hold the songs 30-39 (starting from 0)
	def paginated_songs
		return @paginated_songs
	end
	
	# The options to use when the artist is serialized.
	def serialize_options
		{
			methods: [ :kind, :display, :url, :info, :photo ],
			except: [ :picture ]
		}
	end
	
	# Returns an artist matching a value.
	#
	# The value can be the name (string) of the artist or by a hash describing
	# the artist.
	#
	# The artist will be created if it is not found.
	def self.get(value)		
		if value.is_a? String
			name = value
			value = find_by_name(name.sub("&","&#38;"))
			value = find_by_name(name) unless value
			value = create(name: name) unless value
			
		elsif value.is_a? Hash
			value = get_by_hash(value)
			
		end
		return value if value.is_a?(Artist)
		return nil
	end
	
	# Split an artist name when it contains words like: and, feat, vs
	def self.split_name(name)
		return [] if name.blank?
		name.split(/(?:\s+(?:&|feat(?:uring|s)?|ft|vs|and|with)(?:\s+|\.\s*)|\s*[,\+]\s*)/i)
	end
	
	def self.uniq_name(name)
		split_name(name).map(&:downcase).sort.compact.uniq
	end
	
	private
	
	def self.get_by_hash(hash)
		begin
		
			# look for same source
			logger.debug 'looking for source'
			source = Source.find_by_hash(hash)
			return source.resource if source
			
			# look for same name
			logger.debug 'no source found, getting by name'
			artist = find_by_name(hash[:name])
			artist = create(name: hash[:name]) unless artist
			artist.images_hash = hash
			artist.source = hash
			return artist
			
		rescue StandardError => e
			raise e # TODO: remove this after debugging
		end
		return nil
	end
	
	def self.find_by_name(name)
		where("lower(name)=?", name.downcase).first
	end
end
