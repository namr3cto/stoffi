require 'test_helper'

class SearchTest < ActiveSupport::TestCase
	test "should get suggestions" do
		s = Search.suggest('bob', '/home', 50, 50, 'us')
		assert_equal 5, s.length, "wrong number of suggestions returned"
		assert_equal "bob marley", s[0][:query].downcase, "first suggestion wasn't correct"
	end
	
	test "should prioritize user's" do
		s = Search.suggest('bob', '/home', 50, 50, 'us', users(:alice).id)
		assert_equal 5, s.length, "wrong number of suggestions returned"
		assert_equal "Bob Sinclair", s[0][:query], "first suggestion wasn't correct"
	end
	
	test "should prioritize nearby" do
		s = Search.suggest('bob', '/home', 30, 30, 'us')
		assert_equal 5, s.length, "wrong number of suggestions returned"
		assert_equal "Bob Dylan", s[0][:query], "first suggestion wasn't correct"
	end
	
	test "should prioritize locale" do
		s = Search.suggest('bob', '/home', 50, 50, 'se')
		assert_equal 5, s.length, "wrong number of suggestions returned"
		assert_equal "Bob Andersson", s[0][:query], "first suggestion wasn't correct"
	end
	
	test "should prioritize page" do
		s = Search.suggest('bob', '/artists', 50, 50, 'us')
		assert_equal 5, s.length, "wrong number of suggestions returned"
		assert_equal "Bobby Brown", s[0][:query], "first suggestion wasn't correct"
	end
end
