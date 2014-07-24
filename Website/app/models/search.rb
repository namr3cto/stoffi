class Search < ActiveRecord::Base
	belongs_to :user
	
	def self.suggest(query, page, longitude, latitude, locale, user_id = -1, limit = 10)
		self.select('query, sum(id) as hits').where("query like '?%'", [query]).
		     group('hits').limit(limit)
	end
end
