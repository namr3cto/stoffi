Devise.setup do |config|
	config.mailer_sender = "Stoffi <noreply@stoffiplayer.com>"
	require 'devise/orm/active_record'
	config.case_insensitive_keys = [ :email ]
	config.strip_whitespace_keys = [ :email ]
	config.paranoid = true
	config.stretches = Rails.env.test? ? 1 : 10
	config.remember_for = 2.weeks
	config.password_length = 6..4096
	config.lock_strategy = :failed_attempts
	config.unlock_strategy = :both
	config.maximum_attempts = 10
	config.unlock_in = 5.minutes
	config.reset_password_within = 2.hours
	config.navigational_formats = [:"*/*", "*/*", :html, :mobile, :embedded]
	config.sign_out_via = :delete
	config.secret_key = Rails.application.secrets.devise
end

ActionController::Responder.class_eval do
  alias :to_mobile :to_html
  alias :to_embedded :to_html
end
