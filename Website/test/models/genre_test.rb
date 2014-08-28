require 'test_helper'

class GenreTest < ActiveSupport::TestCase
	def setup
		@hash = {
			name: 'Foo',
			popularity: '123',
			id: 'foo',
			source: :lastfm,
			images: [
				{ url: 'http://foo.com/img1.jpg' },
				{ url: 'http://foo.com/img2.jpg' },
			],
			url: 'http://foo.com/genre1',
			type: :genre
		}
		super
	end
	
	test "should get top genres" do
		g = Genre.top.limit(3)
		assert_equal 3, g.length, "Didn't return three top genres"
		assert g[0].listens.count >= g[1].listens.count, "Top genres not in order (first and second)"
		assert g[1].listens.count >= g[2].listens.count, "Top genres not in order (second and third)"
	end
	
	test "should create genre" do
		g = nil
		assert_difference 'Genre.count', 1, "Didn't create new genre" do
			g = Genre.find_or_create_by_hash(@hash)
		end
		assert g, "Didn't return genre"
		assert_equal @hash[:name], g.name, "Didn't set name"
		
		assert g.images.where(url: @hash[:images][0][:url]).any?, "Didn't set images"
		
		s = g.sources[0]
		assert s, "Didn't set source"
		assert_equal @hash[:popularity].to_f, s.popularity, "Didn't set source popularity"
		assert_equal @hash[:id], s.foreign_id, "Didn't set source id"
		assert_equal @hash[:url], s.foreign_url, "Didn't set source url"
		assert_equal @hash[:source], s.name, "Didn't set source name"
	end
	
	test "should find genre" do
		ska = genres(:ska)
		g = nil
		@hash[:name] = ska.name
		assert_no_difference 'Genre.count', "Created new genre" do
			g = Genre.find_or_create_by_hash(@hash)
		end
		assert_equal ska, g, "Didn't return correct genre"
		
		assert g.images.where(url: @hash[:images][0][:url]).any?, "Didn't set images"
		
		s = g.sources.where(name: :lastfm).first
		assert s, "Didn't set source"
		assert_equal @hash[:popularity].to_f, s.popularity, "Didn't set source popularity"
		assert_equal @hash[:id], s.foreign_id, "Didn't set source id"
		assert_equal @hash[:url], s.foreign_url, "Didn't set source url"
		assert_equal @hash[:source].to_s, s.name, "Didn't set source name"
	end
end
