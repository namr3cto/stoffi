# TODO: some bug caused require error, so I have to do this
#require 'test_helper'
require File.expand_path('../../test_helper', __FILE__)

require 'rails/performance_test_help'

class HomepageTest < ActionDispatch::PerformanceTest
	# Refer to the documentation for all available options
	# self.profile_options = { runs: 5, metrics: [:wall_time, :memory],
	#                          output: 'tmp/performance', formats: [:flat] }

	test "homepage" do
		get root_path
	end
	
	test "download" do
		get get_path
	end
	
	test "barebone" do
		get barebone_path
	end
end
