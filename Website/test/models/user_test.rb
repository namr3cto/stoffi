require 'test_helper'

class UserTest < ActiveSupport::TestCase
	test "should create user" do
		passwd = "foobar"
		assert_difference('User.count', 1, "Didn't create user") do
			User.create(:email => "foo@bar.com", :password => passwd, :password_confirmation => passwd)
		end
	end

	test "should not save user with short password" do
		passwd = "foo"
		assert_no_difference('User.count', "Created user with short password") do
			User.create(:email => "foo@bar.com", :password => passwd, :password_confirmation => passwd)
		end
	end

	test "should not save user without password" do
		assert_no_difference('User.count', "Created user without password") do
			User.create(:email => "foo@bar.com")
		end
	end

	test "should destroy user" do
		alice = users(:alice)
		bob = users(:bob)
		assert_difference('User.count', -1, "Didn't remove user") do
			assert_difference('bob.followings.count', -1, "Didn't remove following") do
				assert_difference('Playlist.count', -1*alice.playlists.count, "Didn't remove playlists") do
					alice.destroy
				end
			end
		end
	end
	
	test "should fetch gravatar images" do
		alice = users(:alice)
		assert alice.gravatar(:mm).starts_with? 'https://gravatar.com/avatar'
		assert alice.gravatar(:monsterid).starts_with? 'https://gravatar.com/avatar'
		alice.image = 'gravatar'
		assert_equal alice.gravatar(:mm), alice.picture
		alice.image = 'identicon'
		assert_equal alice.gravatar(:identicon), alice.picture
	end
	
	test "should get unconnected links" do
		alice = users(:alice)
		unconnected = alice.unconnected_links
		available = Link.available # all links
		
		# ensure connected links are not included
		alice.links.each do |link|
			assert unconnected.select { |l| l[:name] == link.to_s }.length == 0
			
			# remove this from all links
			available.reject! { |l| l[:name] == link.to_s }
		end
		
		# ensure that the left-overs (after removing connected) are all included
		available.each do |link|
			assert_includes unconnected, link
		end
	end
	
	test 'should own' do
		user = users(:alice)
		assert user.owns? user.playlists.first
	end
	
	test 'should not own' do
		assert_not users(:alice).owns? users(:bob).playlists.first
	end
	
	test 'nil should not own' do
		assert_not nil.owns? Playlist.first
	end
end
