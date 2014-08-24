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
		super
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
		s.update_attribute(:updated_at, 2.years.ago)
		get :fetch, { format: :html, id: s.id }
		assert_response :success
		assert_not_nil assigns(:results)
	end

	test "should get fetch cached" do
		s = searches(:Bob_Dylan)
		s.update_attribute(:updated_at, 2.minutes.ago)
		get :fetch, { format: :html, id: s.id }
		assert_response :success
		assert_not_nil assigns(:results)
	end

end
