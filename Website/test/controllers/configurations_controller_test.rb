require 'test_helper'

class ConfigurationsControllerTest < ActionController::TestCase
	include Devise::TestHelpers
	
	setup do
		@config = configurations(:bob_config)
		@admin = users(:alice)
		@user = users(:bob)
		@request.env["devise.mapping"] = Devise.mappings[:user]
	end

	test "should not get index" do
		assert_raises AbstractController::ActionNotFound do
			get :index
		end
	end
	
	test "should get show logged in" do
		sign_in @user
		get :show, id: @config
		assert_redirected_to remote_path
	end
	
	test "should not get show logged out" do
		get :show, id: @config
		assert_redirected_to new_user_session_path
	end
	
	test "should not show missing" do
		sign_in @user
		get :show, id: "foobar"
		assert_response :not_found
	end

	test "should not get new" do
		assert_raises AbstractController::ActionNotFound do
			get :new
		end
	end
	
	test "should not create logged out" do
		assert_no_difference('Configuration.count') do
			post :create, configuration: { name: 'Foo' }
		end
		assert_redirected_to new_user_session_path
	end

	test "should create as user" do
		sign_in @user
		assert_difference('Configuration.count') do
			post :create, configuration: { name: 'Foo' }
		end
		assert_redirected_to configuration_path(assigns(:config))
	end

	test "should not get edit" do
		assert_raises AbstractController::ActionNotFound do
			get :edit, id: @config
		end
	end

	test "should not update when logged out" do
		patch :update, id: @config, configuration: { name: 'New name' }
		assert_redirected_to new_user_session_path
		assert_not_equal 'New name', Configuration.find(@config.id).name, "Changed name"
	end

	test "should update as owner" do
		sign_in @user
		patch :update, id: @config, configuration: { name: 'New name' }
		assert_redirected_to configuration_path(assigns(:config))
		assert_equal 'New name', Configuration.find(@config.id).name, "Didn't change name"
	end

	test "should not update someone elses" do
		sign_in @user
		patch :update, id: @admin.configurations.first, configuration: { name: 'New name' }
		assert_response :not_found
		assert_not_equal 'New name', Configuration.find(@admin.configurations.first.id).name, "Changed name"
	end

	test "should not destroy" do
		assert_raises AbstractController::ActionNotFound do
			get :destroy, id: @config
		end
	end
end
