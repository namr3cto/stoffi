require 'test_helper'

class SearchControllerTest < ActionController::TestCase
	def setup
		@artists = 
		{
			'results' =>
			{
				'opensearch:totalResults' => 3,
				'artistmatches' => { 'artist' =>
					[
						{
							'name' => 'Bob Marley',
							'listeners' => '123',
							'url' => 'http://foo.com/artist/bob_marley',
							'image' => [
								{ '#text' => 'http://img.com/b_s.jpg', 'size' => 'small' },
								{ '#text' => 'http://img.com/b_m.jpg', 'size' => 'medium' },
								{ '#text' => 'http://img.com/b_l.jpg', 'size' => 'large' },
							]
						},
						{
							'name' => 'Damian Marley',
							'listeners' => '12',
							'url' => 'http://foo.com/artist/damian_marley',
							'image' => [
								{ '#text' => 'http://img.com/d_s.jpg', 'size' => 'small' },
								{ '#text' => 'http://img.com/d_m.jpg', 'size' => 'medium' },
								{ '#text' => 'http://img.com/d_l.jpg', 'size' => 'large' },
							]
						},
						{
							'name' => 'Stephen Marley',
							'listeners' => '23',
							'url' => 'http://foo.com/artist/stephen_marley',
							'image' => [
								{ '#text' => 'http://img.com/s_s.jpg', 'size' => 'small' },
								{ '#text' => 'http://img.com/s_m.jpg', 'size' => 'medium' },
								{ '#text' => 'http://img.com/s_l.jpg', 'size' => 'large' },
							]
						}
					]
				}
			}
		}
		WebMock.disable_net_connect!(allow_localhost: true)
		url = /.*img\.com.*jpg/
		path = File.join(Rails.root, 'test/fixtures/image_32x32.png')
		stub_request(:get, url).to_return(:body => File.new(path), :status => 200)
	end	

	test "should get index" do
		get :index
		assert_response :success
	end

	test "should get suggest" do
		get :suggest, format: :json
		assert_response :success
	end

	test "should get fetch" do
		stub_request(:any, /.*ws.audioscrobbler.com.*method=artist\.search.*/).
			to_return(:body => @artists.to_json, :status => 200)
		s = searches(:Bob_Dylan)
		s.update_attribute(:updated_at, 2.weeks.ago)
		get :fetch, { format: :html, q: s.query , c: s.categories, s: s.sources}
		assert_response :success
		assert_not_nil assigns(:results)
		assert_requested :get, /.*ws.audioscrobbler.com.*method=artist\.search.*/
	end

	test "should get fetch cached" do
		s = searches(:bob_marley)
		s.update_attribute(:updated_at, 1.hours.ago)
		get :fetch, { format: :html, q: s.query }
		assert_response :success
		assert_not_nil assigns(:results)
	end

end
