require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'net/http'
require 'oauth/rack/oauth_filter'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Stoffi
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :us

    #config.active_record.observers = :link_backlog_observer, :link_observer, :global_observer
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.available_locales = [:us, :uk, :cn, :de, :se, :en]
    config.i18n.fallbacks = [:us]

    # oauth-plugin requires Rack Filter
    config.middleware.use OAuth::Rack::OAuthFilter

    config.autoload_paths += %W(#{config.root}/app/controllers/backend/*)
  end
end
