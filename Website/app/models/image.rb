class Image < ActiveRecord::Base
	belongs_to :resource, polymorphic: true
	
	def self.create_by_hashes(hashes)
		images = []
		hashes.each do |hash|
			begin
				# Fill missing size attributes
				unless hash.key? :width and hash.key? :height
					size = FastImage.size(hash[:url])
					hash[:width] = size[0]
					hash[:height] = size[1]
				end
			
				images << Image.create(
					url: hash[:url],
					width: hash[:width].to_i,
					height: hash[:height].to_i
				)
			rescue
			end
		end
		return images
	end
	
	def self.get_size(asked_sizes)
		asked_sizes = [asked_sizes] unless asked_sizes.is_a? Array
		available_sizes = {}
		
		all.each do |img|
			available_sizes[size(img.width, img.height)] = img
		end
		
		asked_sizes.each do |s|
			return available_sizes[s] if available_sizes.has_key? s
		end
		
		default_sizes.each do |s|
			return available_sizes[s] if available_sizes.has_key? s
		end
		
		return nil
	end
	
	private
	
	def self.default_sizes
		[:medium, :large, :small, :huge, :tiny]
	end
	
	def self.size(width, height)
		s = width*height
		if s <= 32*32
			return :tiny
		elsif s <= 64*64
			return :small
		elsif s <= 128*128
			return :medium
		elsif s <= 256*256
			return :large
		else
			return :huge
		end
	end
end
