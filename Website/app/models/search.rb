class Search < ActiveRecord::Base
	belongs_to :user
	
	def self.suggest(query, page, longitude, latitude, locale, user_id = -1, limit = 10)
		terms = []
		
		self.select("*, count(*) as hits").where("lower(query) like ?", [query.downcase+'%']).
		     group("lower(query)").order("hits desc").find_each do |search|
			
			weight = 1.0
			debug = {}
			
			if search.page == page
				weight *= score_weights[:page]
			end
			
			if search.locale == locale
				weight *= score_weights[:locale]
			end
			
			if search.user_id.to_i > 0 and user_id.to_i > 0 and search.user_id == user_id
				weight *= score_weights[:user]
			end
			
			longitude ||= 0
			latitude ||= 0
			
			d = Haversine.distance(
				longitude, latitude, search.longitude, search.latitude).to_meters / 10000
			d = 0.001 if d == 0
			weight *= eval(score_weights[:distance].sub('x', d.to_s)).to_f
			
			terms << {query: search.query, score: search.hits.to_f * weight.to_f}
		end
		
		return terms.sort_by { |x| x[:score] }.reverse[0..limit-1]
	end
	
	def self.latest_search(query, categories, sources)
		s = where(query: query, categories: categories, sources: sources)
			.order(:updated_at).limit(1)
		return s.updated_at if s
		return Time.now
	end
	
	private
	def self.score_weights
		{
			# multiply hits with this number if the search occured
			# on the same page
			page: 2,
			
			# multiply hits with this number if the searcher is using
			# the same locale setting
			locale: 3,
			
			# multiply hits with this number if it was made by the
			# same user
			user: 10,
			
			# replace x with distance in 10 km, evaluate and multiply
			# with hits
			distance: '[5, 10.0/x].min'
		}
	end
end
