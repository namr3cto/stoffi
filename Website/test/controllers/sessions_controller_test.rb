require 'test_helper'

class Users::SessionsControllerTest < ActionController::TestCase
	include Devise::TestHelpers
	
	setup do
		@user = users(:alice)
		@request.env["devise.mapping"] = Devise.mappings[:user]
	end

	test "should get new" do
		get :new
		assert_response :success
	end

	test "should not get new when logged in" do
		sign_in @user
		get :new
		assert_redirected_to dashboard_path
	end
	
	test "should get destroy" do
		get :destroy
		assert_redirected_to new_user_session_path
	end
end