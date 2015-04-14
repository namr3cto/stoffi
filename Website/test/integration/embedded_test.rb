require 'test_helper'

class EmbeddedTest < ActionDispatch::IntegrationTest
	fixtures :users
	
	def set_embedded
		cookies[:embedded_param] = '1'
	end
	
	def assert_embedded
		assert_equal :embedded, request.format.to_sym, "Didn't get embedded version"
		assert_equal '1', cookies['embedded_param'], "Didn't set cookie"
	end
	
	test 'get embedded version via cookie' do
		cookies[:embedded_param] = '1'
		get new_user_session_path
		assert_embedded
	end
	
	test 'get embedded version via header' do
		get new_user_session_path, {}, { 'HTTP_X_EMBEDDER' => '1' }
		assert_embedded
	end
	
	test 'get embedded version via user agent' do
		get new_user_session_path, {}, { 'HTTP_USER_AGENT' => 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; WOW64; Trident/5.0; SLCC2; .NET CLR 2.0.50727; .NET4.0C; .NET4.0E)' }
		assert_embedded
	end
	
	test "login" do
		set_embedded
		get_via_redirect dashboard_path
		assert_response :success
		assert_embedded
		
		user = users(:alice)
		passwd = "foobar"
		set_pass(user, passwd)
		
		post_via_redirect new_user_session_path, user: { email: user.email, password: passwd }
		assert_equal dashboard_path, path
		assert_embedded
	end
	
	test "register" do
		set_embedded
		get new_user_registration_path
		assert_response :success
		
		assert_difference "User.count", 1 do
			post_via_redirect new_user_registration_path, user: {
				email: 'foo@bar.com',
				password: 'foobar',
				password_confirm: 'foobar'
			}
		end
		
		assert_equal dashboard_path, path
		assert_embedded
	end
	
	test "fail login with wrong password" do
		set_embedded
		get new_user_session_path
		assert_response :success
		
		user = users(:alice)
		passwd = "foobar"
		
		post_via_redirect new_user_session_path, user: { email: user.email, password: passwd }
		assert_equal new_user_session_path, path
		assert_equal "Invalid email or password.", flash[:alert]
	end
	
	test "fail login with wrong email" do
		get new_user_session_path
		assert_response :success
		
		user = users(:alice)
		passwd = "foobar"
		set_pass(user, passwd)
		
		post_via_redirect new_user_session_path, user: { email: "foobar", password: passwd }
		assert_equal new_user_session_path, path
		assert_equal "Invalid email or password.", flash[:alert]
	end
	
	test "logout" do
		set_embedded
		user = users(:alice)
		passwd = "foobar"
		set_pass(user, passwd)
		post_via_redirect new_user_session_path, user: { email: user.email, password: passwd }
		
		get_via_redirect logout_path
		assert_response :success
		assert_equal new_user_session_path, path
		assert_embedded
		
		get dashboard_path
		assert_response :redirect
	end
end
