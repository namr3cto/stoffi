class Event < ActiveRecord::Base
	has_and_belongs_to_many :artists, join_table: :performances
	
	with_options as: :resource, dependent: :destroy do |assoc|
		assoc.has_many :sources
		assoc.has_many :images
	end
	
	validates :name, :venue, :start, :longitude, :latitude, presence: true
	validates :longitude, :latitude, numericality: true
	validates :name, uniqueness: { scope: [ :start, :venue ] }
	
	def self.find_or_create_by_hash(hash)
		event = find_by_hash(hash)
		event = create_by_hash(hash) unless event
		
		source = Source.find_or_create_by_hash(hash)
		event.sources << source if source and not event.sources.include? source
		
		logger.debug 'check if images'
		if hash.key? :images
			logger.debug '----------- images -------------'
			images = Image.create_by_hashes(hash[:images])
			logger.debug images.inspect
			event.images << images
		end
		
		return event
	end
	
	def self.find_by_hash(hash)
		date = hash[:start_date]
		date = Date.parse(date) if date.is_a? String
		d_upper = date + 1.hour
		d_lower = date - 1.hour
		where("name = ? and venue = ? and start between ? and ?",
			hash[:name], hash[:city], d_lower, d_upper).first
	end
	
	def self.create_by_hash(hash)
		begin
			event = create(
				name: hash[:name],
				venue: hash[:city],
				start: hash[:start_date],
				stop: hash[:end_date],
				category: hash[:category],
			)
			
			if hash.key? :location
				event.longitude = hash[:location][:longitude]
				event.latitude = hash[:location][:longitude]
				event.save
			end
			
			if hash.key? :artists
				hash[:artists].each do |artist|
					artist = Artist.find_or_create_by(name: artist)
					event.artists << artist if artist
				end
			end
			return event
		rescue StandardError => e
			raise e
		end
	end
	
	private
	
	def self.validate_hash(hash)
		raise "Missing name in hash" unless hash.key? :name
		raise "Missing city in hash" unless hash.key? :city
		raise "Missing start date in hash" unless hash.key? :start_date
	end
end
