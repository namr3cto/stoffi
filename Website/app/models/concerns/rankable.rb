module Rankable
	extend ActiveSupport::Concern
	
	module ClassMethods
	
		# Returns the objects sorted by number of listens and popularity
		#
		# options:
		#   for: If this is specified, listens only for this user are
		#        counted
		def top(options = {})
		    tname = self.name.tableize

		    inner_select = self.select("#{tname}.*,COUNT(DISTINCT(listens.id)) AS listens_count").
				joins("LEFT JOIN listens ON listens.song_id = songs.id").
				group("#{tname}.id")
		
			if self.name == 'Event'
		    	inner_select = inner_select.joins(artists: :songs)
			elsif self.name != 'Song'
		    	inner_select = inner_select.joins(:songs)
			end
		    inner_select = inner_select.where("listens.user_id = ?", options[:for].id) if options[:for].is_a? User

			select("#{tname}.*,#{tname}.listens_count,SUM(sources.popularity) AS popularity_count").
				from(inner_select, tname).
				joins("LEFT JOIN sources ON sources.resource_id = #{tname}.id AND sources.resource_type = '#{self.name}'").
				group("#{tname}.id").
				order("listens_count DESC, popularity_count DESC")
		end
		
		def top?
			self.name == 'Song' ? any? : joins(:songs).any?
		end
		
	end
end