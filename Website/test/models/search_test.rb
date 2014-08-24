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
	
	test "should get previous search" do
		searches = Search.order(updated_at: :desc)
		s0 = searches[0]
		s1 = searches[1]
		
		s0.updated_at = 1.second.ago
		s1.updated_at = 5.seconds.ago
		s1.categories = s0.categories
		s1.sources = s0.sources
		s1.query = s0.query
		s0.save!
		s1.save!
		Rails.logger.debug s0.inspect
		Rails.logger.debug s1.inspect
		assert_equal s1.updated_at, s0.previous_at, "Didn't get the correct date"
	end
	
	test "should get previous search from first search" do
		searches = Search.order(:updated_at)
		assert searches.first.previous_at < searches.first.updated_at, "Didn't get the correct date"
	end
end
