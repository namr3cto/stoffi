require 'test_helper'

class SearchTest < ActiveSupport::TestCase
	test "should get suggestions" do
		s = Search.suggest('bob', '/home', 40, 40, 'us')
		assert_equal 4, s.count
	end
end
