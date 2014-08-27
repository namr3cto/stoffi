module Rankable
	extend ActiveSupport::Concern
	
	module ClassMethods
	
		# Returns albums sorted by number of listens and popularity
		#
		# options:
		#   for: If this is specified, listens only for this user are
		#        counted
		def top(options = {})
			tname = self.name.tableize
			x = self.select("#{tname}.*, sum(sources.popularity) as popularity_count, count(listens.id) as listens_count").
			joins(:songs).
			joins("left join sources on sources.resource_id = #{tname}.id and sources.resource_type = '#{self.name}'").
			joins("left join listens on listens.song_id = songs.id")
		
			x = x.where("listens.user_id = ?", options[:for].id) if options[:for].is_a? User
		
			x.group("#{tname}.id").order("listens_count DESC, popularity_count DESC")
		end
		
	end
end