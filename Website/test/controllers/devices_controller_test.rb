require 'test_helper'

class DevicesControllerTest < ActionController::TestCase
	include Devise::TestHelpers
	
	setup do
		@device = devices(:bob_pc)
		@admin = users(:alice)
		@user = users(:bob)
		@request.env["devise.mapping"] = Devise.mappings[:user]
	end

	test "should get index logged in" do
		sign_in @user
		get :index
		assert_response :success
		assert_not_nil assigns(:devices)
	end

	test "should not get index logged out" do
		get :index
		assert_redirected_to new_user_session_path
	end
	
	test "should get show logged in" do
		sign_in @user
		get :show, id: @device
		assert_response :success
	end
	
	test "should not get show logged out" do
		get :show, id: @device
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
		assert_no_difference('Device.count') do
			post :create, device: { name: 'Foo' }
		end
		assert_redirected_to new_user_session_path
	end

	test "should create as user" do
		sign_in @user
		assert_difference('Device.count') do
			post :create, device: { name: 'Foo' }
		end
		assert_redirected_to device_path(assigns(:device))
	end

	test "should not get edit" do
		assert_raises AbstractController::ActionNotFound do
			get :edit, id: @device
		end
	end

	test "should not update when logged out" do
		patch :update, id: @device, device: { name: 'New name' }
		assert_redirected_to new_user_session_path
		assert_not_equal 'New name', Device.find(@device.id).name, "Changed name"
	end

	test "should update as owner" do
		sign_in @user
		patch :update, id: @device, device: { name: 'New name' }
		assert_redirected_to device_path(assigns(:device))
		assert_equal 'New name', Device.find(@device.id).name, "Didn't change name"
	end

	test "should not update someone elses" do
		sign_in @user
		patch :update, id: @admin.devices.first, device: { name: 'New name' }
		assert_redirected_to dashboard_path
		assert_not_equal 'New name', Device.find(@admin.devices.first.id).name, "Changed name"
	end

	test "should update as admin" do
		sign_in @admin
		patch :update, id: @device, device: { name: 'New name' }
		assert_redirected_to device_path(assigns(:device))
		assert_equal 'New name', Device.find(@device.id).name, "Didn't change name"
	end

	test "should not destroy when logged out" do
		assert_no_difference('Device.count') do
			delete :destroy, id: @device
		end
		assert_redirected_to new_user_session_path
	end

	test "should not destroy someone elses" do
		sign_in @user
		assert_no_difference('Device.count') do
			delete :destroy, id: @admin.devices.first
		end
		assert_redirected_to dashboard_path
	end

	test "should destroy as owner" do
		sign_in @user
		assert_difference('Device.count', -1) do
			delete :destroy, id: @device
		end
		assert_redirected_to devices_path
	end

	test "should destroy as admin" do
		sign_in @admin
		assert_difference('Device.count', -1) do
			delete :destroy, id: @device
		end
		assert_redirected_to devices_path
	end
end
