class Source < ActiveRecord::Base
	belongs_to :resource, polymorphic: true

	after_save :reindex_resources
	before_destroy :reindex_resources

	def reindex_resources
		Sunspot.index(resource) if resource
	end
	
	def self.parse_hash(path)
		if path.start_with? 'stoffi:'
			parts = path.split(':', 4)
			{
				resource: parse_resource(parts[1]),
				source: parts[2].to_sym,
				id: parts[3],
			}
		else
			ext = File.extname(path)
			src = :local
			src = :url if path.start_with? 'http://' or path.start_with? 'https://'
			resource = 'Song' if ext.in? SONG_EXT or (ext.empty? and src == :url)
			resource = 'Playlist' if ext.in? PLAYLIST_EXT
			{ source: src, id: path, resource: resource }
		end
	end
	
	def self.parse_path(path)
		raise 'path cannot be nil' unless path
		if path.start_with? 'stoffi:'
			parts = path.split(':', 4)
			{
				resource: parse_resource(parts[1]),
				source: parts[2].to_sym,
				id: parts[3],
			}
		else
			ext = File.extname(path)
			src = :local
			src = :url if path.start_with? 'http://' or path.start_with? 'https://'
			resource = 'Song' if ext.in? SONG_EXT or (ext.empty? and src == :url)
			resource = 'Playlist' if ext.in? PLAYLIST_EXT
			{ source: src, id: path, resource: resource }
		end
	end
	
	def self.find_or_create_by_path(path)
		find_or_create_by(path_to_find_hash(path))
	end
	
	def self.find_by_path(path)
		find_by(path_to_find_hash(path))
	end
	
	def self.find_or_create_by_hash(hash)
		x = find_by_hash(hash)
		x = create_by_hash(hash) unless x
		x
	end
	
	def self.find_by_hash(hash)
		find_by(name: hash[:source], foreign_id: hash[:id], resource_type: hash[:type])
	end
	
	def self.create_by_hash(hash)
		create(
			name: hash[:source],
			foreign_id: hash[:id],
			foreign_url: hash[:url],
			popularity: hash[:popularity]
		)
	end
	
	def path
		case name
		when 'local', 'url' then foreign_id
		else "stoffi:#{resource_type.underscore}:#{name}:#{foreign_id}"
		end
	end
	
	def self.path_to_find_hash(path)
		path = parse_path(path) if path.is_a? String
		{
			name: path[:source],
			foreign_id: path[:id],
			resource_type: parse_resource(path[:resource])
		}
	end
	
	def normalized_popularity
		max = Source.where(name: name, resource_type: resource_type).maximum(:popularity) || 1
		(popularity || 0).to_f / max
	end
	
	def to_s
		case name.downcase
		when 'url' then 'URL'
		when 'lastfm' then 'Last.fm'
		when 'soundcloud' then 'SoundCloud'
		when 'youtube' then 'YouTube'
		else name.capitalize
		end
	end
	
	private
	
	def self.parse_resource(resource)
		resource = 'song' if resource == 'track'
		resource.to_s.singularize.camelize
	end
	
	SONG_EXT = ['.aac', '.ac3', '.aif', '.aiff', '.ape', '.apl', '.bwf', '.flac',
		'.m1a', '.m2a', '.m4a', '.mov', '.mp+', '.mp1', '.mp2', '.mp3', '.mp3pro',
		'.mp4', '.mpa', '.mpc', '.mpeg', '.mpg', '.mpp', '.mus', '.ofr', '.ofs', '.ogg',
		'.spx', '.tta', '.wav', '.wv']
	
	PLAYLIST_EXT = ['.b4s', '.m3u', '.pls', '.ram', '.wpl', '.asx', '.wax',
		'.wvx', '.m3u8', '.xspf', '.xml']
end
