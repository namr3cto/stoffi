require 'test_helper'

class Users::UnlocksControllerTest < ActionController::TestCase
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
	
	test "should send unlock mail" do
		@user.locked_at = Time.now
		@user.save
		post :create, user: { email: @user.email }
		assert_redirected_to new_user_session_path
		email = ActionMailer::Base.deliveries.last
		assert_equal [@user.email], email.to
		assert_equal ['noreply@stoffiplayer.com'], email.from
		assert_match /unlock_token=#{@user.unlock_token}/, email.body.to_s
	end
	
	test "should unlock account" do
		@user.unlock_token = 'foo'
		@user.locked_at = Time.now
		@user.save
		Devise::TokenGenerator.any_instance.expects(:digest).returns('foo')
		get :show, user: {
			reset_password_token: 'foo',
			email: @user.email,
			password: 'a'*10,
			password_confirmation: 'a'*10
		}
		assert_redirected_to new_user_session_path
		assert_not User.find(@user.id).access_locked?, "Didn't unlock account"
	end
	
	test "should not unlock when logged in" do
		sign_in @user
		@user.update_attribute(:unlock_token, 'foo')
		get :show, unlock_token: 'foo'
		assert_redirected_to dashboard_path
	end
end