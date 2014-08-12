class Source < ActiveRecord::Base
	belongs_to :resource, polymorphic: true
	
	def self.parse_path(path)
		raise 'path cannot be nil' unless path
		begin
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
			resource = 'song' if ext.in? SONG_EXT or (ext.empty? and src == :url)
			resource = 'playlist' if ext.in? PLAYLIST_EXT
			{ source: src, id: path, resource: resource }
		end
		rescue
		end
	end
	
	def self.find_or_create_by_path(path)
		find_or_create_by(path_to_find_hash(path))
	end
	
	def self.find_by_path(path)
		find_by(path_to_find_hash(path))
	end
	
	private
	
	def self.parse_resource(resource)
		resource = 'song' if resource == 'track'
		resource.singularize.camelize
	end
	
	def self.path_to_find_hash(path)
		path = parse_path(path) if path.is_a? String
		{
			name: path[:source],
			foreign_id: path[:id],
			resource_type: parse_resource(path[:resource])
		}
	end
	
	SONG_EXT = ['.aac', '.ac3', '.aif', '.aiff', '.ape', '.apl', '.bwf', '.flac',
		'.m1a', '.m2a', '.m4a', '.mov', '.mp+', '.mp1', '.mp2', '.mp3', '.mp3pro',
		'.mp4', '.mpa', '.mpc', '.mpeg', '.mpg', '.mpp', '.mus', '.ofr', '.ofs', '.ogg',
		'.spx', '.tta', '.wav', '.wv']
	
	PLAYLIST_EXT = ['.b4s', '.m3u', '.pls', '.ram', '.wpl', '.asx', '.wax',
		'.wvx', '.m3u8', '.xspf', '.xml']
end
