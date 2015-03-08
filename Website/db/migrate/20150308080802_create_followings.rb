class CreateFollowings < ActiveRecord::Migration
	def change
		create_table :followings do |t|
			t.references :follower, polymorphic: true, index: true
			t.references :followee, polymorphic: true, index: true
		end
		Playlist.each do |playlist|
			playlist.subscribers.each do |user|
			end
		end
	end
end
