class Genre < ActiveRecord::Base
	has_and_belongs_to_many :songs, uniq: true
	with_options through: :songs do |assoc|
		assoc.has_many :artists
		assoc.has_many :albums
	end
	
	validates :name, presence: true
	
	searchable do
		text :name
	end
end
