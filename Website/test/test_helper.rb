# -*- encoding : utf-8 -*-
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'webmock/minitest'
require 'capybara/rails'

class ActiveSupport::TestCase
	# Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
	#
	# Note: You'll currently still have to declare fixtures explicitly in integration tests
	# -- they do not yet inherit this setting
	fixtures :all

	# Add more helper methods to be used by all tests here...
	def setup
		Rails.cache.clear
		WebMock.disable_net_connect!(allow_localhost: true)
		url = /http:\/\/.*\.jpe?g/
		path = File.join(Rails.root, 'test/fixtures/image_32x32.png')
		stub_request(:get, url).to_return(:body => File.new(path), :status => 200)
	end

	def teardown
		Rails.cache.clear rescue nil
	end
end

class ActionController::TestCase
	def setup
		WebMock.disable_net_connect!(allow_localhost: true)
		url = /http:\/\/.*\.jpe?g/
		path = File.join(Rails.root, 'test/fixtures/image_32x32.png')
		stub_request(:get, url).to_return(:body => File.new(path), :status => 200)
	end
	
	def stub_for_settings
		lastfm_link = links(:alice_lastfm)
		lastfm_response = Object.new
		def lastfm_response.parsed
			{ 'user' => { 'name' => 'lfm_name', 'realname' => 'Lastfm Name' }}
		end
		lastfm_url = "/2.0/?method=user.getinfo&format=json&user=#{lastfm_link.uid}&api_key=somerandomid"
		OAuth2::AccessToken.any_instance.expects(:get).times(0..99).with(lastfm_url).returns(lastfm_response)
		
		twitter_link = links(:alice_twitter)
		twitter_response = Object.new
		def twitter_response.body
			{ 'screename' => 'tw_name', 'name' => 'Twitter Name' }.to_json
		end
		twitter_url = "https://api.twitter.com/1.1/users/show.json?user_id=#{twitter_link.uid}"
		OAuth::AccessToken.any_instance.expects(:request).times(0..99).with(:get, twitter_url, nil).returns(twitter_response)
		
		facebook_response = Object.new
		def facebook_response.parsed
			{ 'username' => 'fb_name', 'name' => 'Facebook Name' }
		end
		OAuth2::AccessToken.any_instance.expects(:get).times(0..99).with("/me?fields=name,username").returns(facebook_response)
		OAuth2::AccessToken.any_instance.expects(:get).times(0..99).with("/me/picture?type=large&redirect=false").returns(facebook_response)
	end
end

class ActionDispatch::IntegrationTest
	include Capybara::DSL
	
	def set_pass(user, passwd)
		params = { password: passwd, password_confirmation: passwd }
		assert user.update_with_password(params), "Could not change password"
		assert user.valid_password?(passwd), "Password did not change properly"
	end
	
	def sign_in(user)
		pw = (0...20).map { ('a'..'z').to_a[rand(26)] }.join
		set_pass user, pw
		post_via_redirect new_user_session_path, user: { email: user.email, password: pw }
	end
end

require 'mocha/setup'
