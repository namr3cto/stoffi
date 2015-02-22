require 'test_helper'

class PagesControllerTest < ActionController::TestCase
	
	test "should get index" do
		get :index
		assert_response :success
	end
	
	test "should get news" do
		get :news
		assert_response :success
	end
	
	test "should get tour" do
		get :tour
		assert_response :success
	end
	
	test "should get contact" do
		get :contact
		assert_response :success
	end
	
	test "should get legal" do
		get :legal
		assert_response :success
	end
	
	test "should send contact mail" do
		get :mail, name: 'Alice', email: 'alice@mail.com', subject: 'A Title', message: 'my message is not very short'
		assert_redirected_to contact_path(sent: :success)
		email = ActionMailer::Base.deliveries.last
		assert_equal ['info@stoffiplayer.com'], email.to
		assert_equal ['alice@mail.com'], email.reply_to
		assert_match /my message is not very short/, email.body.to_s
	end
	
	test "should get download button" do
		[
			'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; Trident/6.0)', # windows 7
		].each do |ua|
			@request.headers["HTTP_USER_AGENT"] = ua
			get :get
			assert_response :success
			assert_select 'section#download a.button', nil, "Didn't get download button for #{ua}"	
		end
	end
	
	test "should not get download button" do
		[
			'Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko', # win 8.1
			'Mozilla/5.0 (Windows NT 6.2; Trident/7.0; rv:11.0) like Gecko', # win 8
			'Mozilla/4.0 (compatible; MSIE 7.0; Windows Phone OS 7.0; Trident/3.1; IEMobile/7.0; foo;bar)', # win phone
			'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)', # win xp
			'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9) AppleWebKit/537.71 (KHTML, like Gecko)', # os x
			'Mozilla/5.0 (X11; Linux i586; rv:31.0) Gecko/20100101 Firefox/31.0', # linux
			'Mozilla/5.0 (Linux; Android 4.0.4; Galaxy Nexus Build/IMM76B) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.133 Mobile Safari/535.19', # android
			'Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/538.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25', # iPhone
			'Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/538.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25', # iPad
			
		].each do |ua|
			cookies[:skip_old] = true
			@request.headers["HTTP_USER_AGENT"] = ua
			get :get
			assert_response :success
			assert_select 'section#download p.message', nil, "Got download button for #{ua}"
		end
	end
	
	test "should download binary" do
		get :download
		assert_response :success
		
		assert_not_nil assigns(:filename), "Didn't assign @filename"
		assert_not_nil assigns(:path), "Didn't assign @path"
		assert_not_nil assigns(:url), "Didn't assign @url"
		assert assigns(:url).ends_with?('/InstallStoffi.exe'), "URL doesn't point to an executable"
		
		assert_select "meta[http-equiv='refresh']" do
			assert_select "[content='1;URL=#{assigns(:url)}']"
		end
		assert_select "a[href='#{assigns(:url)}']"
	end
	
	test "should download bundled binary" do
		get :download, fat: '1'
		assert_response :success
		
		assert_not_nil assigns(:filename), "Didn't assign @filename"
		assert_not_nil assigns(:path), "Didn't assign @path"
		assert_not_nil assigns(:url), "Didn't assign @url"
		assert assigns(:url).ends_with?('/InstallStoffiAndDotNet.exe'), "URL doesn't point to a bundled executable"
		
		assert_select "meta[http-equiv='refresh']" do
			assert_select "[content='1;URL=#{assigns(:url)}']"
		end
		assert_select "a[href='#{assigns(:url)}']"
	end
	
	test "should download checksum" do
		get :checksum
		assert_response :success
		
		assert_not_nil assigns(:filename), "Didn't assign @filename"
		assert_not_nil assigns(:path), "Didn't assign @path"
		assert_not_nil assigns(:url), "Didn't assign @url"
		assert assigns(:url).ends_with?('/InstallStoffi.sum'), "URL doesn't point to a checksum file"
		
		assert_select "meta[http-equiv='refresh']" do
			assert_select "[content='1;URL=#{assigns(:url)}']"
		end
		assert_select "a[href='#{assigns(:url)}']"
	end
	
	test "should not get old browser warning on new browsers" do
		new_browsers = [
			'Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko', # ie
			'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9) AppleWebKit/537.71 (KHTML, like Gecko)', # safari
			'Mozilla/5.0 (X11; Linux i586; rv:31.0) Gecko/20100101 Firefox/31.0', # firefox
			'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.111 Safari/537.36', # chrome
			'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.111 Safari/537.36', # opera
			
		].each do |ua|
			cookies.delete(:skip_old)
			@request.headers["HTTP_USER_AGENT"] = ua
			get :index
			assert_response :success
			assert_select 'main#old', false, "Got old browser warning for #{ua}"
		end
	end
	
	test "should get old browser warning" do
		[
			'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)',
			'Mozilla/5.0 (X11; Linux i586; rv:31.0) Gecko/20100101 Firefox/5.0',
			'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9) AppleWebKit/400.71 (KHTML, like Gecko)'
		].each do |ua|
			cookies.delete(:skip_old)
			@request.headers["HTTP_USER_AGENT"] = ua
			get :index
			assert_response :success
			assert_select 'main#old', nil, "Didn't get old browser warning for #{ua}"
		end
	end
	
	test "should get pass old browser warning" do
		[
			'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)',
			'Mozilla/5.0 (X11; Linux i586; rv:31.0) Gecko/20100101 Firefox/5.0',
			'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9) AppleWebKit/400.71 (KHTML, like Gecko)'
		].each do |ua|
			cookies[:skip_old] = true
			@request.headers["HTTP_USER_AGENT"] = ua
			get :index
			assert_response :success
			assert_select 'main#old', false, "Could not get pass old browser warning on #{ua}"
		end
	end
	
end