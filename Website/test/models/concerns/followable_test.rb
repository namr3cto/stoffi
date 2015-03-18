require 'test_helper'

class FollowableTest < ActiveSupport::TestCase
	
	setup do
		@playlist = playlists(:foo)
		@user = users(:bob)
	end
	
	test "should follow" do
		assert_not_includes @playlist.followers, @user
		assert_not_includes @user.following(Playlist), @playlist
		assert_not @user.follows?(@playlist)
		@user.follow @playlist
		assert_includes @playlist.followers, @user
		assert_includes @user.following(Playlist), @playlist
		assert @user.follows?(@playlist)
	end
	
	test "should unfollow" do
		@user.follow @playlist
		assert_includes @playlist.followers, @user
		assert_includes @user.following(Playlist), @playlist
		@user.unfollow @playlist
		assert_not_includes @playlist.followers, @user
		assert_not_includes @user.following(Playlist), @playlist
	end
	
	test "should not follow own" do
		assert_raises RuntimeError do
			@playlist.user.follow @playlist
		end
	end
	
	test "should remove followings when destryed" do
		@user.follow @playlist
		assert_difference "@user.following(Playlist).count", -1 do
			@playlist.destroy
		end
	end
end