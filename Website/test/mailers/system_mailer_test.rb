require 'test_helper'

class SystemMailerTest < ActionMailer::TestCase
	
	test "contact" do
		email = SystemMailer.contact(
			name: 'Alice User',
			from: 'alice@example.com',
			subject: 'just a test',
			message: 'a short msg'
			).deliver
			
		assert_not ActionMailer::Base.deliveries.empty?
		assert_equal ['noreply@stoffiplayer.com'], email.from
		assert_equal ['alice@example.com'], email.reply_to
		assert_equal ['info@stoffiplayer.com'], email.to
		assert_equal read_fixture('contact').join, email.body.to_s
	end
	
end