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
end