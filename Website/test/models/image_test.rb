require 'test_helper'

class ImageTest < ActiveSupport::TestCase
	test 'should create by hash' do
		imgs = [
			{ url: 'http://foobar.com/default.jpg', width: 120, height: 90 },
			{ url: 'http://foobar.com/mqdefault.jpg', width: 320, height: 180 },
			{ url: 'http://foobar.com/hqdefault.jpg', width: 480, height: 360 },
			{ url: 'http://foobar.com/sddefault.jpg', width: 640, height: 480 },
			{ url: 'http://foobar.com/maxresdefault.jpg', width: 1280, height: 720 },
		]
		images = nil
		assert_difference('Image.count', imgs.length, "Didn't create new images") do
			images = Image.create_by_hashes(imgs)
		end
		
		assert_equal images.count, images.count, "Didn't create all images"
		assert_equal images[0][:width], images[0].width, "Didn't set correct size"
		assert_equal images[0][:url], images[0].url, "Didn't set correct url"
	end
	
	test 'should not return duplicate url' do
		imgs = [
			{ url: 'http://foo.com/tiny.jpg', width: 120, height: 90 },
			{ url: 'http://foobar.com/mqdefault.jpg', width: 320, height: 180 },
			{ url: 'http://foobar.com/hqdefault.jpg', width: 480, height: 360 },
			{ url: 'http://foobar.com/sddefault.jpg', width: 640, height: 480 },
			{ url: 'http://foobar.com/maxresdefault.jpg', width: 1280, height: 720 },
		]
		assert_difference('Image.count', imgs.length - 1, "Didn't create correct images") do
			Image.create_by_hashes(imgs)
		end
	end
	
	test 'should fill in missing size' do
		url = 'http://foobar.com/image.jpg'
		path = File.join(Rails.root, 'test/fixtures/image_32x32.png')
		stub_request(:get, url).to_return(:body => File.new(path), :status => 200)
		imgs = [ { url: url } ]
		images = Image.create_by_hashes(imgs)
		assert_equal 32, images[0].width, "Didn't set correct width"
		assert_equal 32, images[0].height, "Didn't set correct height"
	end
	
	test 'should get exact size' do
		song = songs(:one_love)
		img = song.images.get_size(:tiny)
		assert_equal images(:tiny), img, "Didn't get the correct image"
	end
	
	test 'should get default size' do
		song = songs(:one_love)
		img = song.images.get_size(:invalid)
		assert_equal images(:medium), img, "Didn't get the correct image"
	end
	
	test 'should get size by priority' do
		song = songs(:one_love)
		img = song.images.get_size([:invalid, :another, :large, :tiny])
		assert_equal images(:large), img, "Didn't get the correct image"
	end
	
  # test "the truth" do
  #   assert true
  # end
end
