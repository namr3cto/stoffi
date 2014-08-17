# -*- encoding : utf-8 -*-
# The model of the song resource.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2013 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

require 'base'

# Describes a song in the database.
class Song < ActiveRecord::Base
	extend StaticBase
	include Base

	# associations
	has_and_belongs_to_many :albums, uniq: true
	has_and_belongs_to_many :artists, uniq: true
	has_and_belongs_to_many :users, uniq: true
	has_and_belongs_to_many :playlists, uniq: true
	has_many :listens
	has_many :shares, as: :object
	has_many :sources, as: :resource
	has_many :images, as: :resource
	
	searchable do
		text :title, boost: 5
		text :artists do
			artists.map(&:name)
		end
		string :locations, multiple: true do
			locations.map { |location| location }
		end
	end
	
	# The art of the song.
	def picture(size = :medium)
		return art_url if art_url.present? and not art_url.to_s.downcase == "null"
		return "/assets/media/disc.png"
	end
	
	# A prettified description of the song.
	def pretty_name
		# TODO: internationalize
		s = title
		s += " by #{artist.name}" if artist
		return s
	end
	
	# The full name of the song, including the artist.
	def full_name
		s = title
		s = "#{artist.name} - #{s}" if artist
		return s
	end
	
	# The artist of the song.
	def artist
		artists == nil ? nil : artists.first
	end
	
	# The album of the song.
	def album
		albums == nil ? nil : albums.first
	end
	
	# The string to display to users for representing the resource.
	def display
		title
	end
	
	# A long description of the song.
	def description
		s = "#{title}, a song "
		s+= "by #{artist.name} " if artist
		s+= "on Stoffi"
	end
	
	def xpath
		return nil if sources.length == 0
		src = sources.first
		"stoffi:track:#{src.name}:#{src.foreign_id}"
	end
	
	def locations
		sources.collect { |x| x.name }.uniq.reject { |x| x.to_s.empty? }
	end
	
	# The options to use when the song is serialized.
	def serialize_options
		{
			methods: [ :kind, :display, :url, :picture ]
		}
	end
	
	# Searches for songs which are files.
	def self.search_files(search, limit = 5)
		if search
			search = e(search)
			self.join(:sources).where("songs.title LIKE ? AND sources.name 'local'", "%#{search}%").
			limit(limit)
		else
			scoped
		end
	end
	
	# Returns a song matching a hash of values, describing the song.
	#
	# The value should be a hash with the following structure:
	#  title: the name of the song
	#  path: the path of the song (required)
	#  length: the length of the song, in seconds
	#  artist: the name of the artist
	#    or
	#  artists: an array with each artist
	#  album: the name of the album to which the song belongs
	#  art_url: a url to an image for the song
	#
	# If ask_backend is true and the path points to an external
	# service such as YouTube or SoundCloud, then that service
	# will be queried for info instead of using what is provided
	# in the hash value.
	#
	# The song will be created if it is not found
	def self.get(current_user, value, ask_backend = true)
		raise 'missing path key in hash' unless value.has_key? :path
		begin
			v = value
			v[:path] = fix_old_path(v[:path])
			p = Source.parse_path(v[:path])
			
			case p[:source]
			when :local, :url
				song = find_by_path_and_length(p, v[:length].to_f)
				song = create_from_hash(v) unless song.is_a? Song
			else
				if ask_backend
					song = get_by_path(p)
				else
					song = find_by_path(p)
					song = create_from_hash(v) unless song.is_a? Song
				end
			end
			
			if current_user and song and not current_user.songs.include? song
				current_user.songs << song
			end
			return song
			
		rescue StandardError => e
			raise e
			logger.error "could not get song: #{e.message}"
		end
	end
	
	# Finds a song given its path.
	#
	# If no song is found but exists on an external service then it will be created and saved to the database.
	def self.get_by_path(path)
		# ensure backwards compatibility
		path = parse_path(path) if path.is_a? String
		
		begin
			song = find_by_path(path)
			return song if song.is_a? Song
			
			case path[:source]
			when :youtube
				songs = Backend::Youtube.get_songs([path[:id]])
			when :soundcloud
				songs = Backend::Soundcloud.get_songs([path[:id]])
			end
			
			if songs.is_a? Array and songs.length > 0
				return create_from_hash(songs[0])
			end
		rescue StandardError => e
			raise e
		end
		return nil
	end
	
	def self.find_by_path(path)
	 	return nil if path[:source].in? [:local, :url]
		src = Source.find_by_path(path)
		return src.resource if src
		return nil
	end
	
	def self.find_by_path_and_length(path, length)
		w = "? < length and length < ? and name = ? and foreign_id = ?"
		low = length-0.01
		upp = length+0.01
		sources = Source.where(w, low, upp, path[:source], path[:id])
		l = sources.length
		return nil if l == 0
		return sources[0].resource if l == 1
		raise "multiple sources matching length: #{length} and path: #{path}"
	end
	
	# Returns a top list of songs with most plays.
	#
	# If <tt>user</tt> is supplied then only listens of that user will be considered.
	def self.top(limit = 5, user = nil)
		self.select("songs.id, songs.title, songs.art_url, count(listens.id) AS listens_count").
		joins("LEFT JOIN listens ON listens.song_id = songs.id").
		where(user == nil ? "" : "listens.user_id = #{user.id}").
		group("songs.id").
		order("listens_count DESC").
		limit(limit)
	end
	
	# Extracts the title and artists from a string.
	def self.parse_title(str)
		return "", "" if str.blank?
		
		artist, title = split_title(str)
		
		# remove enclosings
		["'.*'", "\".*\"", "\\(.*\\)", "\\[.*\\]"].each do |e|
			artist = artist[1..-2] if artist.match(e)
			title = title[1..-2] if title.match(e)
		end
		
		# trim start and end
		chars = "-_\\s"
		artist.gsub!(/\A[#{chars}]+|[#{chars}]+\Z/, "")
		title.gsub!(/\A[#{chars}]+|[#{chars}]+\Z/, "")
		
		return artist, title
	end
	
	def self.create_from_hash(hash)
		s = hash
		song = nil
		begin
			artists = extract_artists(s)
			artist, title = parse_title(s[:name] || s[:title])
			artists = [artist] if artists.empty?
		
			song = Song.new
			song.title = title
			song.genre = s[:genre]
			song.images << Image.create_by_hashes(s[:images])
			
			if song.save
				logger.debug 'song was saved successfully'
				if s[:album].present?
					album = Album.get(s[:album])
					song.albums << album if album
				end
				
				logger.debug artists.inspect
				artists.each do |a|
					_a = Artist.get(a) if a.present?
					song.artists << _a if _a
					_a.albums << album if album and not _a.albums.include?(album)
				end
				
				src = Source.find_or_create_by_path(s[:path])
				src.foreign_url = s[:foreign_url] || s[:url]
				src.length = s[:length].to_f if s[:length]
				src.popularity = s[:popularity]
				song.sources << src
			end
		rescue StandardError => e
			raise e
			logger.error "could not create song from hash: #{e.message}"
		end
		return song
	end
	
	private
	
	def self.extract_artists(song)
		artists = []
		if song.has_key? :artists
			artists = song[:artists]
		elsif song.has_key? :artist
			artists = Artist.split_name(song[:artist])
		end
		retval = []
		artists.each do |a|
			artist = Artist.get(a)
			retval << artist if artist
		end
		song.delete(:artist)
		song.delete(:artists)
		return retval
	end
	
	def self.fix_old_path(path)
		if path.starts_with? "youtube://"
			id = path["youtube://".length .. -1]
			return "stoffi:track:youtube:#{id}"
		
		elsif path.starts_with? "soundcloud://"
			id = path["soundcloud://".length .. -1]
			return "stoffi:track:soundcloud:#{id}"
			
		else
			return path
		end
	end
	
	def self.split_title(str)
		# remove meta phrases
		meta = ["official video", "lyrics", "with lyrics",
		"hq", "hd", "official", "official audio", "alternate official video"]
		meta = meta.map { |x| ["\\("+x+"\\)","\\["+x+"\\]"] }.flatten
		meta << "official video"
		meta.each { |m| str = str.gsub(/#{m}/i, "") }
		
		# remove multi whitespace
		str = str.split.join(" ")
		
		# split on - : ~ by
		separators = []
		["-", ":", "~"].each {|s| separators.concat [" "+s, s+" ", " "+s+" "]}
		separators.map! { |s| [s, true] } # true is for left=artist
		separators << [", by ", false] # false is for right=artist
		separators << [" by ", false]
		separators.each do |sep|
			next unless str.include? sep[0]
			
			s = str.split(sep[0], 2)
			artist = s[sep[1]?0:1]
			title = s[sep[1]?1:0]
			
			# stuff that gives us a hint that the string is an artist
			["by ", "ft ", "ft.", "feat ", "feat.", "with "].each do |artistText|
				
				# remove prefix
				if artist.downcase.starts_with? artistText
					return artist[artistText.length..-1], title
					
				# swap and remove prefix
				elsif title.downcase.starts_with? artistText
					return title, artist[artistText.length..-1]
					
				# swap
				elsif title.downcase.include?(" "+artistText)
					return title, artist
				end
			end
			
			return artist, title
		end
		
		# title in quotes
		# ex: Eminem "Not Afraid"
		t = "(\'(?<title>.+)\'|\"(?<title>.+)\")"
		a = "(?<artist>.+)"
		p = "(#{t}\\s+#{a}|#{a}\\s+#{t})"
		m = str.match(p)
		return m[:artist], m[:title] if m
		
		return "", str
	end
end
