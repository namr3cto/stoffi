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
		assert_response :success
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
		assert_redirected_to configuration_path(assigns(:configuration))
	end

	test "should not get edit" do
		assert_raises AbstractController::ActionNotFound do
			get :edit, id: @configuration
		end
	end

	test "should not update when logged out" do
		patch :update, id: @configuration, configuration: { name: 'New name' }
		assert_redirected_to new_user_session_path
		assert_not_equal 'New name', Configuration.find(@configuration.id).name, "Changed name"
	end

	test "should update as owner" do
		sign_in @user
		patch :update, id: @configuration, configuration: { name: 'New name' }
		assert_redirected_to configuration_path(assigns(:configuration))
		assert_equal 'New name', Configuration.find(@configuration.id).name, "Didn't change name"
	end

	test "should not update someone elses" do
		sign_in @user
		patch :update, id: @admin.configurations.first, configuration: { name: 'New name' }
		assert_redirected_to dashboard_path
		assert_not_equal 'New name', Configuration.find(@admin.configurations.first.id).name, "Changed name"
	end

	test "should update as admin" do
		sign_in @admin
		patch :update, id: @configuration, configuration: { name: 'New name' }
		assert_redirected_to configuration_path(assigns(:configuration))
		assert_equal 'New name', Configuration.find(@configuration.id).name, "Didn't change name"
	end

	test "should not destroy when logged out" do
		assert_no_difference('Configuration.count') do
			delete :destroy, id: @configuration
		end
		assert_redirected_to new_user_session_path
	end

	test "should not destroy someone elses" do
		sign_in @user
		assert_no_difference('Configuration.count') do
			delete :destroy, id: @admin.configurations.first
		end
		assert_redirected_to dashboard_path
	end

	test "should destroy as owner" do
		sign_in @user
		assert_difference('Configuration.count', -1) do
			delete :destroy, id: @configuration
		end
		assert_redirected_to configurations_path
	end

	test "should destroy as admin" do
		sign_in @admin
		assert_difference('Configuration.count', -1) do
			delete :destroy, id: @configuration
		end
		assert_redirected_to configurations_path
	end
end
