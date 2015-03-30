require 'test_helper'

class Users::RegistrationsControllerTest < ActionController::TestCase
	include Devise::TestHelpers
	
	setup do
		@admin = users(:alice)
		@user = users(:bob)
		@request.env["devise.mapping"] = Devise.mappings[:user]
	end

	test "should not get own profile when logged out" do
		get :show
		assert_redirected_to new_user_session_path
	end

	test "should get others profile when logged out" do
		get :show, id: users(:bob)
		assert_response :success
	end

	test "should get profile while logged in" do
		sign_in @user
		get :show
		assert_response :success
	end

	test "should not get dashboard when logged out" do
		get :dashboard
		assert_redirected_to new_user_session_path
	end

	test "should get dashboard while logged in" do
		sign_in @user
		get :dashboard
		assert_response :success
	end

	test "should not get settings when logged out" do
		get :edit
		assert_redirected_to new_user_session_path
	end

	test "should get settings while logged in" do
		stub_for_settings
		sign_in @user
		get :edit
		assert_response :success
	end
	
	test "should not update when logged out" do
		post :update, id: @user, user: { email: 'new@mail.com' }
		assert_not_equal 'new@mail.com', @user.email, "Changed email"
	end
	
	test "should update own account" do
		sign_in @user
		post :update, user: { email: 'new@mail.com' }
		assert_redirected_to edit_user_registration_path
		assert_equal 'new@mail.com', User.find(@user.id).email, "Didn't change email"
	end
	
	test "should not make self admin" do
		sign_in @user
		post :update, user: { admin: true }
		assert_response :success
		assert_not User.find(@user.id).admin?, "Made self admin"
	end
	
	# TODO: should display errors
	
	test "should not update other account" do
		sign_in @user
		post :update, id: users(:charlie), user: { email: 'new@mail.com' }
		assert_redirected_to edit_user_registration_path
		assert_not_equal 'new@mail.com', User.find(users(:charlie).id).email, "Changed email"
	end
	
	test "should update other account when admin" do
		sign_in @admin
		post :update, id: users(:charlie), user: { email: 'new@mail.com' }
		assert_redirected_to edit_user_registration_path
		assert_equal 'new@mail.com', User.find(users(:charlie).id).email, "Didn't change email"
	end
	
	test "should delete profile" do
		sign_in @user
		@user.follow users(:alice).playlists.first
		
		assert_difference('User.count', -1) do
		assert_difference('Playlist.count', @user.playlists.count * -1) do
		assert_difference('Listen.count', @user.listens.count * -1) do
		assert_difference('Share.count', @user.shares.count * -1) do
		assert_difference('Link.count', @user.links.count * -1) do
		assert_difference('Device.count', @user.devices.count * -1) do
		assert_difference('ClientApplication.count', @user.apps.count * -1) do
		assert_difference('users(:bob).followings.count', -1) do
			delete :destroy
			assert_redirected_to new_user_session_path, "Not redirected to login page"
		end end end end end end end end
		
		assert_raises ActiveRecord::RecordNotFound do
			User.find(@user.id)
		end
		
		# TODO: possible to make this prettier?
		Playlist.all.each do |playlist|
			assert playlist.followers.where(id: @user.id).empty?
		end
	end
end