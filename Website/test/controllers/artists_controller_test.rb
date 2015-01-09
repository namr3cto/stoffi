require 'test_helper'

class ArtistsControllerTest < ActionController::TestCase
	include Devise::TestHelpers
	
	setup do
		@artist = artists(:bob_marley)
		@admin = users(:alice)
		@user = users(:bob)
	end

	test "should get index" do
		get :index
		assert_response :success
		assert_not_nil assigns(:artists)
	end

	test "should redirect for get new when logged out" do
		get :new
		assert_redirected_to new_user_session_path
	end

	test "should redirect for get new when not admin" do
		sign_in @user
		get :new
		assert_redirected_to dashboard_path
	end
	
	test "should get new" do
		sign_in @admin
		get :new
		assert_response :success
	end

	test "should redirect create artist when logged out" do
		assert_no_difference('Artist.count') do
			post :create, artist: { name: 'Foo' }
		end

		assert_redirected_to new_user_session_path
	end

	test "should redirect create artist when not admin" do
		sign_in @user
		assert_no_difference('Artist.count') do
			post :create, artist: { name: 'Foo' }
		end

		assert_redirected_to dashboard_path
	end

	test "should create artist" do
		sign_in @admin
		assert_difference('Artist.count') do
			post :create, artist: { name: 'Foo' }
		end

		assert_redirected_to artist_path(assigns(:artist))
	end

	test "should show artist" do
		get :show, id: @artist
		assert_response :success
	end

	test "should redirect for get edit when logged out" do
		get :edit, id: @artist
		assert_redirected_to new_user_session_path
	end

	test "should redirect for get edit when not admin" do
		sign_in @user
		get :edit, id: @artist
		assert_redirected_to dashboard_path
	end

	test "should get edit" do
		sign_in @admin
		get :edit, id: @artist
		assert_response :success
	end

	test "should redirect for update artist when logged out" do
		patch :update, id: @artist, artist: { name: @artist.name }
		assert_redirected_to new_user_session_path
	end

	test "should redirect for update artist when not admin" do
		sign_in @user
		patch :update, id: @artist, artist: { name: @artist.name }
		assert_redirected_to dashboard_path
	end

	test "should update artist" do
		sign_in @admin
		patch :update, id: @artist, artist: { name: @artist.name }
		assert_redirected_to artist_path(assigns(:artist))
	end

	test "should redirect for destroy artist when logged out" do
		assert_no_difference('Artist.count') do
		  delete :destroy, id: @artist
		end

		assert_redirected_to new_user_session_path
	end

	test "should redirect for destroy artist when not admin" do
		sign_in @user
		assert_no_difference('Artist.count') do
		  delete :destroy, id: @artist
		end

		assert_redirected_to dashboard_path
	end

	test "should destroy artist" do
		sign_in @admin
		assert_difference('Artist.count', -1) do
		  delete :destroy, id: @artist
		end

		assert_redirected_to artists_path
	end
end
