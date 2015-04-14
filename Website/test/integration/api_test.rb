require 'test_helper'

class ApiTest < ActionDispatch::IntegrationTest
	
	setup do
		@admin = users(:alice)
		@user = users(:bob)
		Link.any_instance.expects(:name).at_least(0).returns('test name')
		SyncController.expects(:send).at_least(0)
	end
	
	test 'get user' do
		sign_in @user
		get 'me.json'
		assert_response :success
		assert_equal @user.to_json, response.body
	end
	
	test "create device" do
		sign_in @user
		assert_difference "@user.devices.count", +1 do
			post 'devices.json', { device: { name: 'new device', version: 'test' } }
		end
		assert_response :created
		body = JSON::parse(response.body)
		assert body['id'].to_i > 0
	end
	
	test 'get device' do
		device = @user.devices.first
		sign_in @user
		get device_url(device, format: :json)
		assert_response :success
		body = JSON::parse(response.body)
		assert_equal device.id, body['id'].to_i
		assert_equal device.name, body['name']
	end
	
	test 'list links' do
		@user = users(:charlie)
		sign_in @user
		get 'links.json'
		assert_response :success
		body = JSON::parse(response.body)
		assert_equal JSON::parse(@user.links.to_json), body['connected']
	end
	
	test 'get link' do
		@user = users(:charlie)
		link = @user.links.first
		sign_in @user
		get link_url(link, format: :json)
		assert_response :success
		assert_equal link.to_json, response.body
	end
	
	test 'update link' do
		@user = users(:charlie)
		link = @user.links.first
		do_listen = link.do_listen
		sign_in @user
		patch link_url(link, format: :json), { link: { do_listen: !do_listen } }
		assert_response :success
		assert_equal !do_listen, Link.find(link.id).do_listen, "Didn't change setting"
	end
	
	test 'delete link' do
		@user = users(:charlie)
		link = @user.links.first
		sign_in @user
		assert_difference "@user.links.count", -1 do
			delete link_url(link, format: :json)
		end
		assert_response :no_content
	end
	
	test 'list playlists' do
		
	end
	
	test 'get playlist' do
		
	end
	
	test 'get someone elses playlist' do
		
	end
	
	test 'follow playlist' do
		
	end
	
	test 'unfollow playlist' do
		
	end
	
	test 'create playlist' do
		
	end
	
	test 'update playlist' do
		
	end
	
	test 'share playlist' do
		
	end
	
	test 'delete playlist' do
		
	end
	
	test 'get sync profile' do
		
	end
	
	test 'update sync profile' do
		
	end
	
	test 'start listen' do
		
	end
	
	test 'update listen' do
		
	end
	
	test 'end listen' do
		
	end
	
	test 'delete listen' do
		
	end
	
	test 'share song' do
		
	end
end
