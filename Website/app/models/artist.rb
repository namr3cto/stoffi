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
	extend StaticBase
	include Base
	
	# associations
	has_and_belongs_to_many :albums, uniq: true
	has_and_belongs_to_many :songs, uniq: true
	has_and_belongs_to_many :artists, join_table: :performances, uniq: true
	has_many :wikipedia_links, as: :resource
	has_many :listens, through: :songs
	has_many :donations
	
	# validations
	validates_uniqueness_of :name
	validates_presence_of :name
	
	# Defines the default picture to use when no picture of the artist can be found.
	def self.default_pic
		"/assets/media/artist.png"
	end
	
	# Returns the picture of the artist.
	#
	# Will try to find a picture on Last.fm, if none is found then a default picture will be returned.
	# The picture is saved to the database so searching will only occur the first time this method is called.
	def picture
		s = super
		return s if s.to_s != ""
		
		# try to find image
		if name.to_s != ""
			pic = nil
			begin
				key = Rails.application.secret.oa_cred[:lastfm][:id]
				q = CGI.escapeHTML(e(name)).gsub(/\s/, "%20")
				url_base = "ws.audioscrobbler.com"
				url_path = "/2.0?method=artist.info&format=json&api_key=#{key}&artist=#{q}"
				logger.info "fetching artist image for #{name} from http://#{url_base}#{url_path}"
				http = Net::HTTP.new(url_base)
				res, data = http.get(url_path, nil)
				feed = JSON.parse(data)
				logger.debug "searching for image of size: large"
				feed['artist']['image'].each do |img|
					pic = img['#text']
					break if img['size'] == 'large'
				end
				
				pic = Artist.default_pic if pic.to_s == ""
				
			rescue => err
				logger.error "could not retrieve artist image: " + err.to_s
				pic = Artist.default_pic
			end
				
			if pic
				update_attribute(:picture, pic)
				return pic
			end
		end
		
		return Artist.default_pic
	end
	
	# Whether or not the artist has a Twitter account.
	def twitter?; twitter.to_s != "" end
	# Whether or not the artist has a Facebook page or account.
	def facebook?; facebook.to_s != "" end
	# Whether or not the artist has a Google+ account.
	def googleplus?; googleplus.to_s != "" end
	# Whether or not the artist has a MySpace account.
	def myspace?; myspace.to_s != "" end
	# Whether or not the artist has a YouTube channel or account.
	def youtube?; youtube.to_s != "" end
	# Whether or not the artist has a SoundCloud account.
	def soundcloud?; soundcloud.to_s != "" end
	# Whether or not the artist has a Spotify presence.
	def spotify?; spotify.to_s != "" end
	# Whether or not the artist has a Last.fm presence.
	def lastfm?; lastfm.to_s != "" end
	# Whether or not the artist has a website.
	def website?; website.to_s != "" end
	
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
		return name.to_s == ""
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
		unknown? || donatable_status.to_s == ""
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
			:methods => [ :kind, :display, :url, :info, :photo ],
			:except => [ :picture ]
		}
	end
	
	# Searches for artists.
	def self.search(search, limit = 5)
		if search
			search = e(search)
			self.select("artists.id, artists.name, artists.picture, count(listens.id) AS listens_count").
			joins(:songs).
			joins("LEFT JOIN listens ON listens.song_id = songs.id").
			where("artists.name LIKE ?", "%#{search}%").
			group("artists.id").
			limit(limit)
		else
			scoped
		end
	end
	
	# Returns an artist matching a value.
	#
	# The value can be the ID (integer) or the name (string) of the artist.
	# The artist will be created if it is not found (unless <tt>value</tt> is an ID).
	def self.get(value)
		value = self.find(value) if value.is_a?(Integer)
		if value.is_a?(String)
			name = value
			value = self.find_by(name: name.sub("&","&#38;"))
			value = self.find_or_create_by(name: name) unless value.is_a?(Artist)
		end
		return value if value.is_a?(Artist)
		return nil
	end
	
	# Returns a top list of artists.
	#
	# The argument <tt>type</tt> can be:
	#
	# :played:: The most played artists.
	# :supported:: The artist with the most donations.
	#
	# If <tt>user</tt> is supplied then only listens or donations of that user will be considered.
	def self.top(limit = 5, type = :played, user = nil)
		case type
		when :supported
			self.select("artists.id, artists.name, artists.picture, sum(donations.amount) AS c").
			joins(:donations).
			where(user == nil ? "" : "donations.user_id = #{user.id}").
			where("donations.status != 'returned' AND donations.status != 'failed' AND donations.status != 'revoked'").
			group("artists.id").
			order("c DESC")
			
		when :played
			self.select("artists.id, artists.name, artists.picture, count(listens.id) AS c").
			joins(:songs).
			joins("LEFT JOIN listens ON listens.song_id = songs.id").
			where(user == nil ? "" : "listens.user_id = #{user.id}").
			where("artists.name != '' AND artists.name IS NOT NULL").
			group("artists.id").
			order("c DESC").
			limit(limit)
		
		else
			raise "Unsupported type"
		end
	end
	
	# Split an artist name when it contains words like: and, feat, vs
	def self.split_name(name)
		name.split(/(?:\s+(?:&|feat(?:uring|s)?|ft|vs|and)(?:\s+|\.\s*)|\s*[,\+]\s*)/i)
	end
end
