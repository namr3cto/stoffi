module Genreable
	extend ActiveSupport::Concern
	
	def genre=(text)
		text.to_s.split(',').each do |name|
			genre = Genre.find_or_create_by(name: name.strip)
			genres << genre unless genres.include? genre
		end
	end
	
	def genre
		genres.map(&:name).join(', ')
	end
	
	module ClassMethods
		
		def find_or_create_by_hash(hash)
			o = super(hash)
			if hash.key? :genre
				g = Genre.find_or_create_by_hash(hash)
				o.genre << g unless o.genres.include? g
			end
			o
		end
		
	end
end