# -*- encoding : utf-8 -*-
c = Rails.application.secrets.oa_cred

OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
	provider :facebook, c['facebook']['id'], c['facebook']['key'],
	{
		:client_options => {:ssl => {:ca_path => "/etc/ssl/certs"}},
		:scope => 'publish_actions, offline_access'
	}
		
	provider :twitter, c['twitter']['id'], c['twitter']['key']
	
	provider :google_oauth2, c['google_oauth2']['id'], c['google_oauth2']['key'],
	         :scope => [
	         	"https://www.googleapis.com/auth/userinfo.profile",
	         	"https://www.googleapis.com/auth/userinfo.email",
	         	"https://www.googleapis.com/auth/plus.me"
	         ].join(' '),
	         :approval_prompt => "force", :access_type => "offline"
		
	provider :linkedin, c['linkedin']['id'], c['linkedin']['key']
	
	provider :vimeo, c['vimeo']['id'], c['vimeo']['key']
	
	provider :soundcloud, c['soundcloud']['id'], c['soundcloud']['key']
	
	provider :myspace, c['myspace']['id'], c['myspace']['key']
	
	provider :lastfm, c['lastfm']['id'], c['lastfm']['key']
	
	provider :vkontakte, c['vkontakte']['id'], c['vkontakte']['key'],
	         :scope => 'friends,audio,wall,offline', :display => 'page'
		
	provider :windowslive, c['windowslive']['id'], c['windowslive']['key'],
	         :scope => 'wl.basic,wl.offline_access,wl.share'
		
	provider :yandex, c['yandex']['id'], c['yandex']['key'],
	         :access_type => "offline"
	
	provider :yahoo, c['yahoo']['id'], c['yahoo']['key'], :access_type => "offline"
		
	provider :weibo, c['weibo']['id'], c['weibo']['key']
	
	#provider :foursquare, c[:foursquare][:key], c[:foursquare][:key], {:client_options => {:ssl => {:ca_path => "/etc/ssl/certs"}}}
	#provider :openid, OpenID::Store::Filesystem.new('/tmp'), :name => 'yahoo', :identifier => 'yahoo.com'
	#provider :googleApps, OpenID::Store::Filesystem.new('/tmp'), :name => 'admin', :domain => 'stoffiplayer.com'
	#provider :rdio, c[:rdio][:id], c[:rdio][:key]
end
