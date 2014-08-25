module Sourceable
	extend ActiveSupport::Concern
	
	included do
		has_many :sources, as: :resource, dependent: :destroy
	end
	
	def source=(hash)
		return unless hash.key?(:source) and hash.key?(:id)
		return unless sources.where(name: hash[:source]).empty?
		src = Source.new
		src.name = hash[:source]
		src.foreign_id = hash[:id]
		src.foreign_url = hash[:url]
		src.popularity = hash[:popularity]
		sources << src if src.save
	end
	
	def popularity
		sources.inject(0) { |sum,x| sum + x.normalized_popularity }
	end
	
	def locations
		sources.map(&:name).uniq.reject { |x| x.to_s.empty? }.sort
	end
end