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
	include Base
	include Imageable
	include Sourceable
	include Genreable
	include Rankable
	include Duplicatable

	# associations
	with_options uniq: true do |assoc|
		assoc.has_and_belongs_to_many :albums
		assoc.has_and_belongs_to_many :users
		assoc.has_and_belongs_to_many :playlists
		assoc.has_and_belongs_to_many :genres
		
		assoc.has_and_belongs_to_many :artists do
			def == (a)
				a = a.join(',') if a.is_a? Array
				Artist.uniq_name(self.join(',')) == Artist.uniq_name(a)
			end
		end
	end
	with_options as: :resource do |assoc|
		assoc.has_many :sources
		assoc.has_many :images
		assoc.has_many :shares
	end
	has_many :listens
	
	# include duplicates' association into self's
	include_associations_of_dups :listens, :shares, :artists
	
	self.default_image = "gfx/icons/256/missing.png"
	
	searchable do
		text :title, boost: 5
		text :artist_names
		string :locations, multiple: true do
			sources.map(&:name)
		end
	end
	
	# The string to display to users for representing the resource.
	def display
		title
	end
	
	def artist_names
		artists.collect { |a| a.name }.to_sentence
	end
	
	def artists=(names)
		artists.clear
		Artist.split_name(names).each do |artist|
			artists << Artist.find_or_create_by(name: artist)
		end
	end
	
	# A long description of the song.
	# TODO: belongs in view!
	def description
		s = "#{title}, a song "
		s+= "by #{artist_names} " if artists.length > 0
		s+= "on Stoffi"
	end
	
	alias_method :subtitle, :artist_names
	
	def fullname
		"#{artist_names} - #{title}"
	end
	
	def similar(count = 5)
		s = []
		
		# collect associations
		genres.each { |x| s << x } if genres.count > 0
		albums.each { |x| s << x } if albums.count > 0
		artists.each { |x| s << x } if artists.count > 0
		
		# retrieve songs from associations
		r = []
		s.each do |x|
			r.concat x.songs.where.not(id: id).offset(rand(x.songs.count-5)).limit(count).to_a
		end
		
		# shuffle and return
		r.shuffle[0..count-1]
	end
	
	# The options to use when the song is serialized.
	def serialize_options
		{
			methods: [ :kind, :display, :url, :image, :artist_names, :subtitle ]
		}
	end
	
	# Returns a song matching a hash of values, describing the song.
	#
	# The value should be an ID or a hash with the following structure:
	#  title: the name of the song
	#  path: the path of the song (required)
	#  length: the length of the song, in seconds
	#  artist: the name of the artist
	#    or
	#  artists: an array with each artist
	#  album: the name of the album to which the song belongs
	#  art_url: a url to an image for the song
	#
	# If value is a hash and ask_backend is true, and the path points
	# to an external service such as YouTube or SoundCloud, then that
	# service will be queried for info instead of using what is provided
	# in the hash value.
	#
	# If value is a hash, the song will be created if it is not found.
	def self.get(current_user, value, ask_backend = true)
		
		# value is an ID (as integer or string)
		value = value.to_i if value.is_a?(String)
		if value.is_a? Integer
			return Song.find(value)
		end
		
		# value is a hash
		v = value
		validate_hash(v)
		
		v[:title] ||= v[:name]
		v[:genre] ||= v[:genres]
		
		if v[:title].present?
			song = find_by_hash(v)
			return song if song.is_a? Song
		end
		
		begin
			if v[:path]
				v[:path] = fix_old_path(v[:path])
				p = Source.parse_path(v[:path])
			else
				p = {
					name: v[:source],
					foreign_id: v[:id],
					resource: v[:type]
				}
			end
			
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
	
	def self.find_by_hash(h)
		artists, title = artists_and_title(h)
		s = self.where('lower(title) = ?', title.downcase).first
		return s if s and s.artists == artists
		return nil
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
	
	# Extracts the title and artists from a string.
	def self.parse_title(str)
		return "", "" if str.blank?
		
		artist, title = split_title(str)
		
		# remove enclosings
		["'.*'", "\".*\"", "\\(.*\\)", "\\[.*\\]"].each do |e|
			e = "/^#{e}$/"
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
			artists, title = artists_and_title(s)
		
			song = Song.new
			song.title = title
			
			if song.save
				song.genre = s[:genre]
				song.images << Image.create_by_hashes(s[:images])
			
				if s[:album].present?
					album = Album.get(s[:album])
					song.albums << album if album
				end
				
				artists.each do |a|
					_a = Artist.get(a) if a.present?
					song.artists << _a if _a
					_a.albums << album if album and not _a.albums.include?(album)
				end
				
				if s.key? :path
					src = Source.find_or_create_by_path(s[:path])
				else
					src = Source.find_or_create_by_hash(s)
				end
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
	
	def self.artists_and_title(h)
		artists = extract_artists(h)
		title = h[:title] || h[:name]
		if artists.empty?
			artist, title = parse_title(title) 
			artists = [artist]
		end
		return artists.compact.sort.uniq, title
	end
	
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
		#song.delete(:artist)
		#song.delete(:artists)
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
		# ex: Eminem - Not Afraid
		#     Eminem: Not Afraid
		#     Not Afraid, by Eminem
		separators = []
		["-", ":", "~"].each {|s| separators.concat [" "+s, s+" ", " "+s+" "]}
		separators.map! { |s| [s, true] } # true is for left=artist
		separators << [", by ", false] # false is for right=artist
		separators << [" by ", false]
		separators.each do |sep|
			next unless str.include? sep[0]
			
			s = str.split(sep[0], 2)
			artist = s[sep[1]?0:1].strip
			title = s[sep[1]?1:0].strip
			
			# stuff that adds additional artists at the end
			parts = title.split(/\s+(?:by|ft|feat|featuring|with)(?:\s+|\.\s*)/)
			return artist,title if parts.length == 1
			
			return ([artist] << parts[1..-1]).join(', '), parts[0]
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
	
	def self.validate_hash(h)
		has_name = (h.key?(:name) or h.key?(:title))
		has_path = h.key?(:path)
		has_source = h.key?(:source) and h.key?(:id) and h.key?(:type)
		unless has_name or has_path or has_source
			raise "hash needs to contain either\n"+
				"\t:name or :title\n"+
				"\t:path\n"+
				"\t:source, :id, and :type"
		end
	end
end
