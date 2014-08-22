module Imageable
	extend ActiveSupport::Concern
	
	included do
		has_many :images, as: :resource, dependent: :destroy
		class_attribute :default_image
		self.default_image = "/assets/media/artist.png"
	end
	
	def image(size = :medium)
		img = images.get_size(size) unless images.empty?
		return img.url if img
		return default_image
	end
end