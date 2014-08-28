require 'test_helper'

class GenreTest < ActiveSupport::TestCase
	test "should get top genres" do
		g = Genre.top.limit(3)
		assert_equal 3, g.length, "Didn't return three top genres"
		assert g[0].listens.count >= g[1].listens.count, "Top genres not in order (first and second)"
		assert g[1].listens.count >= g[2].listens.count, "Top genres not in order (second and third)"
	end
end
