require 'test_helper'

class Users::PasswordsControllerTest < ActionController::TestCase
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
	
	test "should create password reset" do
		post :create, user: { email: @user.email }
		assert_redirected_to new_user_session_path
		email = ActionMailer::Base.deliveries.last
		assert_equal [@user.email], email.to
		assert_equal ['noreply@stoffiplayer.com'], email.from
		assert_match /reset_password_token=#{@user.reset_password_token}/, email.body.to_s
	end
	
	test "should get edit" do
		@user.update_attribute(:reset_password_token, 'foo')
		get :edit, reset_password_token: 'foo'
		assert_response :success
	end
	
	test "should not get edit when logged in" do
		sign_in @user
		@user.update_attribute(:reset_password_token, 'foo')
		get :edit, reset_password_token: 'foo'
		assert_redirected_to dashboard_path
	end
	
	test "should reset password" do
		Devise::TokenGenerator.any_instance.expects(:digest).returns('foo')
		@user.reset_password_token = 'foo'
		@user.reset_password_sent_at = Time.now
		@user.save
		old_password = @user.encrypted_password
		post :update, user: {
			reset_password_token: 'foo',
			email: @user.email,
			password: 'a'*10,
			password_confirmation: 'a'*10
		}
		assert_redirected_to dashboard_path
		assert_not_equal old_password, User.find(@user.id).encrypted_password, "Didn't change password"
	end
end