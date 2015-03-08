class Following < ActiveRecord::Base
	
	with_options polymorphic: true do |assoc|
		assoc.belongs_to :follower
		assoc.belongs_to :followee
	end
end