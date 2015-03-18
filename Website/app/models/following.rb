class Following < ActiveRecord::Base
	
	with_options polymorphic: true do |assoc|
		assoc.belongs_to :follower
		assoc.belongs_to :followee
	end
	
	validates :followee_id, uniqueness: { scope:
		[:follower_id, :follower_type, :followee_type] }
end