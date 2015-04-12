require 'test_helper'

class OauthClientsControllerTest < ActionController::TestCase
	include Devise::TestHelpers
	
	setup do
		@admin = User.where(admin: true).first
		@user = User.where(admin: false).first
		@app = client_applications(:myapp)
		@app_params = {
			name: 'NewApp',
			website: 'http://www.website.com',
			support_url: 'https://www.website.com/support',
			callback_url: 'http://www.website.com/callback',
			key: 'somerandomappkey',
			secret: 'asecretrandomstringformyapp',
			icon_16: 'http://website.com/myapp_16.png',
			icon_64: 'http://website.com/myapp_64.png',
			description: 'A test app',
			author: 'Tester',
			author_url: 'http://www.tester.com'
		}

	end

	test "should get index logged in" do
		sign_in @user
		get :index
		assert_response :success
		assert_not_nil assigns(:popular)
		assert_not_nil assigns(:added)
		assert_not_nil assigns(:created)
	end

	test "should get index logged out" do
		get :index
		assert_response :success
		assert_not_nil assigns(:popular)
		assert_nil assigns(:added)
		assert_nil assigns(:created)
	end
	
	test "should get show logged in" do
		sign_in @user
		get :show, id: @app
		assert_response :success
	end
	
	test "should get show logged out" do
		get :show, id: @app
		assert_response :success
	end
	
	test "should not show missing" do
		get :show, id: "foobar"
		assert_response :not_found
	end

	test "should get new logged in" do
		sign_in @user
		get :new
		assert_response :success
	end

	test "should not get new logged out" do
		get :new
		assert_redirected_to new_user_session_path
	end
	
	test "should not create logged out" do
		assert_no_difference('ClientApplication.count') do
			post :create, client_application: @app_params
		end
		assert_redirected_to new_user_session_path
	end

	test "should create as user" do
		sign_in @user
		assert_difference('ClientApplication.count') do
			post :create, client_application: @app_params
		end
		assert_redirected_to app_path(assigns(:app))
	end

	test "should not get edit logged out" do
		post :edit, id: @app
		assert_redirected_to new_user_session_path
	end

	test "should not get edit as user" do
		@app.user = users(:charlie)
		@app.save
		sign_in users(:bob)
		post :edit, id: @app
		assert_redirected_to dashboard_path
	end

	test "should get edit as owner" do
		@app.user = users(:charlie)
		@app.save
		sign_in @app.user
		post :edit, id: @app
		assert_response :success
	end

	test "should get edit as admin" do
		@app.user = users(:charlie)
		@app.save
		sign_in @admin
		post :edit, id: @app
		assert_response :success
	end

	test "should not update logged out" do
		patch :update, id: @app, client_application: { name: 'New name' }
		assert_redirected_to new_user_session_path
		assert_not_equal 'New name', ClientApplication.find(@app.id).name, "Changed name"
	end

	test "should not update as user" do
		@app.user = users(:charlie)
		@app.save
		sign_in users(:bob)
		patch :update, id: @app, client_application: { name: 'New name' }
		assert_redirected_to dashboard_path
		assert_not_equal 'New name', ClientApplication.find(@app.id).name, "Changed name"
	end

	test "should update as owner" do
		@app.user = users(:charlie)
		@app.save
		sign_in @app.user
		patch :update, id: @app, client_application: { name: 'New name' }
		assert_redirected_to app_path(assigns(:app))
		assert_equal 'New name', ClientApplication.find(@app.id).name, "Didn't change name"
	end

	test "should update as admin" do
		sign_in @admin
		patch :update, id: @app, client_application: { name: 'New name' }
		assert_redirected_to app_path(assigns(:app))
		assert_equal 'New name', ClientApplication.find(@app.id).name, "Didn't change name"
	end

	test "should not destroy logged out" do
		assert_no_difference('ClientApplication.count') do
			delete :destroy, id: @app
		end
		assert_redirected_to new_user_session_path
	end

	test "should not destroy as user" do
		@app.user = users(:charlie)
		@app.save
		sign_in users(:bob)
		assert_no_difference('ClientApplication.count') do
			delete :destroy, id: @app
		end
		assert_redirected_to dashboard_path
	end

	test "should destroy as owner" do
		@app.user = users(:charlie)
		@app.save
		sign_in @app.user
		assert_difference('ClientApplication.count', -1) do
			delete :destroy, id: @app
		end
		assert_redirected_to apps_path
	end

	test "should destroy as admin" do
		sign_in @admin
		assert_difference('ClientApplication.count', -1) do
			delete :destroy, id: @app
		end
		assert_redirected_to apps_path
	end
end
