require 'test_helper'

class SongsControllerTest < ActionController::TestCase
	include Devise::TestHelpers
	setup do
		@song = songs(:not_afraid)
		@user = users(:bob)
		@admin = users(:alice)
	end

	test "should get index" do
		get :index
		assert_response :success
		assert_not_nil assigns(:recent)
		assert_not_nil assigns(:weekly)
		assert_not_nil assigns(:alltime)
	end

	test "should show song" do
		get :show, id: @song
		assert_response :success
	end

	test "should show archetype" do
		real_song = songs(:one_love)
		@song.duplicate_of real_song
		get :show, id: @song
		assert_redirected_to song_path(real_song)
	end

	test "should not update song when signed out" do
		patch :update, id: @song, song: { title: @song.title }
		assert_redirected_to new_user_session_path
	end

	test "should not update song when user" do
		sign_in @user
		patch :update, id: @song, song: { title: 'foo' }
		assert_redirected_to dashboard_path
		assert_not_equal 'foo', assigns(:song).title
	end

	test "should update song when admin" do
		sign_in @admin
		patch :update, id: @song, song: { title: 'foo' }
		assert_redirected_to song_path(assigns(:song))
		assert_equal 'foo', assigns(:song).title
	end

	test "should mark as duplicate" do
		sign_in @admin
		assert_not @song.duplicate?, "Was marked as duplicate before test"
		patch :update, id: @song, song: { archetype: songs(:no_woman_no_cry) }
		assert_redirected_to song_path(@song)
		assert assigns(:song).duplicate?, "Didn't mark as duplicate"
	end

	test "should unmark as duplicate" do
		sign_in @admin
		@song.duplicate_of songs(:no_woman_no_cry)
		assert @song.duplicate?, "Wasn't marked as duplicate before test"
		patch :update, id: @song, song: { archetype: '' }
		assert_redirected_to song_path(@song)
		assert_not assigns(:song).duplicate?, "Didn't unmark as duplicate"
	end
end
