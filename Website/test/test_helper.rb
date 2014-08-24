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
		Rails.cache.clear
	end
end

class ActionController::TestCase
	def setup
		WebMock.disable_net_connect!(allow_localhost: true)
		url = /http:\/\/.*\.jpe?g/
		path = File.join(Rails.root, 'test/fixtures/image_32x32.png')
		stub_request(:get, url).to_return(:body => File.new(path), :status => 200)
	end
end

class ActionDispatch::IntegrationTest
	include Capybara::DSL
end

require 'mocha/setup'
