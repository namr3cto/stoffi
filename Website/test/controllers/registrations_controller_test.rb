require 'test_helper'

class Users::RegistrationsControllerTest < ActionController::TestCase
	include Devise::TestHelpers
	
	setup do
		@user = users(:alice)
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
	
	test "should delete profile" do
		sign_in @user
		
		assert_difference('User.count', -1) do
		assert_difference('Playlist.count', @user.playlists.count * -1) do
		assert_difference('Listen.count', @user.listens.count * -1) do
		assert_difference('Share.count', @user.shares.count * -1) do
		assert_difference('Link.count', @user.links.count * -1) do
		assert_difference('Device.count', @user.devices.count * -1) do
		assert_difference('ClientApplication.count', @user.apps.count * -1) do
		assert_difference('users(:bob).playlist_subscriptions.count', -1) do
			delete :destroy
			assert_redirected_to new_user_session_path, "Not redirected to login page"
		end end end end end end end end
		
		assert_raises ActiveRecord::RecordNotFound do
			User.find(@user.id)
		end
		
		# TODO: possible to make this prettier?
		Playlist.all.each do |playlist|
			assert playlist.subscribers.where(id: @user.id).empty?
		end
	end
end