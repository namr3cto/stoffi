module Imageable
	extend ActiveSupport::Concern
	
	included do
		has_many :images, as: :resource, dependent: :destroy
		class_attribute :default_image
		self.default_image = "gfx/icons/256/missing.png"
	end
	
	def image(size = :medium)
		img = images.get_size(size) unless images.empty?
		return img.url if img
		return default_image
	end
	
	def images_hash=(hash)
		return unless hash.key?(:images)
		imgs = Image.create_by_hashes(hash[:images])
		images << imgs
	end
	
	module ClassMethods
		
		def find_or_create_by_hash(hash)
			o = super(hash)
			o.images << Image.create_by_hashes(hash[:images]).reject { |i| o.images.include? i } if hash.key? :images
			o
		end
		
	end
end