# -*- encoding : utf-8 -*-
Stoffi::Application.routes.draw do

	scope "(:l)", :l => /us|uk|se|cn|de|--/ do

		namespace :admin do
			resources :translatees
			resources :translatee_params
			resources :configs
		end
		
		as :user do
			get "login",         :to => "users/sessions#new",            :as => :login
			get "logout",        :to => "devise/sessions#destroy",       :as => :logout
			get "join",          :to => "users/registrations#new",       :as => :join
			delete "leave",      :to => "users/registrations#destroy",   :as => :leave
			get "forgot",        :to => "users/passwords#new",           :as => :forgot
			get "reset",         :to => "users/passwords#edit",          :as => :reset
			get "unlock",        :to => "users/unlocks#new",             :as => :unlock
			get "dashboard",     :to => "users/registrations#dashboard", :as => :dashboard
			put "settings",      :to => "users/registrations#settings",  :as => :settings
			
			get "profile(/:user_id)/playlists", :to => "playlists#by"
			get "profile(/:id)", :to => "users/registrations#show",      :as => :profile
			
			get "me/playlists", :to => "playlists#by"
			get "me",            :to => "users/registrations#show",      :as => :me
			
			# handle failed omniauth
			get "auth/failure", :to => "users/sessions#new"
			
			# we need to overwrite default X_path for proper redirection from devise
			post "login",  :to => "users/sessions#create",      :as => :xxuser_session
			post "login",  :to => "users/sessions#create",      :as => :xxnew_user_session
			get  "login",  :to => "users/sessions#new",         :as => :xxxnew_user_session
			
			post "join",     :to => "users/registrations#create", :as => :xxuser_registration
			get  "join",     :to => "users/registrations#new",    :as => :xxnew_user_registration
			get  "settings", :to => "users/registrations#edit",  :as => :xxedit_user_registration
			
			post "forgot", :to => "users/passwords#create",     :as => :xxuser_password
			get  "forgot", :to => "users/passwords#new",        :as => :xxnew_user_password
			get  "reset",  :to => "users/passwords#create",     :as => :xxedit_user_password
			put  "reset",  :to => "users/passwords#update",     :as => :xxxedit_user_password
			
			post "unlock", :to => "devise/unlocks#create",      :as => :xxuser_unlock
			get  "unlock", :to => "devise/unlocks#new",         :as => :xxnew_user_unlock
			
			get "profile(/:id)", :to => "users/registrations#show",      :as => :user
		end
		
		devise_for :user, :controllers =>
		{
			:registrations => "users/registrations",
			:sessions => "users/sessions",
			:passwords => "users/passwords",
			:unlocks => "users/unlocks"
		}
		resources :users

		get "youtube/:action" => "youtube"
		
		get "/news",       :to => "pages#news",       :as => :news
		get "/tour",       :to => "pages#tour",       :as => :tour
		get "/get",        :to => "pages#get",        :as => :get
		get "/download",   :to => "pages#download",   :as => :download
		get "/contact",    :to => "pages#contact",    :as => :contact
		get "/about",      :to => "pages#about",      :as => :about
		get "/legal",      :to => "pages#legal",      :as => :legal
		get "/money",      :to => "pages#money",      :as => :money
		get "/remote",     :to => "pages#remote",     :as => :remote
		get "/history",    :to => "pages#history",    :as => :history
		get "/language",   :to => "pages#language",   :as => :lang
		get "/donate",     :to => "pages#donate",     :as => :donate
		get "/mail",       :to => "pages#mail",       :as => :mail
		get "/facebook",   :to => "pages#facebook",   :as => :facebook
		get "/channel",    :to => "pages#channel",    :as => :facebook_channel
		get "/old",        :to => "pages#old",        :as => :old
		get "/foo",        :to => "pages#foo",        :as => :foo

		resources :translations, :languages, :votes
		resources :songs, :artists, :events, :genres
		resources :links, :devices
		resources :oauth_clients, :path => "apps", :as => :client_application
		resources :oauth_clients, :path => "apps", :as => :oauth_clients
		resources :oauth_clients, :path => "apps", :as => :apps do
			member do
				delete "revoke"
			end
		end
		
		resources :listens do
			member do
				post "end"
			end
			collection do
				get "by/:user_id", :to => "listens#by"
			end
		end
		
		resources :albums do
			collection do
				get "/by/:artist_id", :to => "albums#by"
			end
		end
		
		resources :playlists do
			member do
				put "follow"
			end
			collection do
				get "/by/:user_id", :to => "playlists#by"
			end
		end
		
		resources :shares do
			collection do
				get "/by/:user_id", :to => "shares#by"
			end
		end
		
		resources :donations do
			collection do
				get "/by/:user_id", :to => "donations#by"
			end
		end
		
		resources :configurations do
			member do
				post "next"
				post "prev"
				put "play"
				put "pause"
				post "play_pause", :path => "play-pause"
			end
		end

		get   "/oauth/test_request",      :to => "oauth#test_request",      :as => :test_request
		get   "/oauth/token",             :to => "oauth#token",             :as => :token
		post  "/oauth/access_token",      :to => "oauth#access_token",      :as => :access_token
		post  "/oauth/request_token",     :to => "oauth#request_token",     :as => :request_token
		match "/oauth/authorize",         :to => "oauth#authorize",         :as => :authorize,		via: [:get, :post]
		get   "/oauth/revoke",            :to => "oauth#revoke",            :as => :revoke
		get   "/oauth",                   :to => "oauth#index",             :as => :oauth
		
		get "/auth/:provider/callback" => "links#create"

		get '/search/suggest'
		get '/search/fetch'
		get "/search/(:categories)",      :to => "search#index",     :as => :search
	end
	
	get "(:l)" => "pages#index", :as => :root

	# The priority is based upon order of creation:
	# first created -> highest priority.

	# Sample of regular route:
	#   get "products/:id" => "catalog#view"
	# Keep in mind you can assign values other than :controller and :action

	# Sample of named route:
	#   get "products/:id/purchase" => "catalog#purchase", :as => :purchase
	# This route can be invoked with purchase_url(:id => product.id)

	# Sample resource route (maps HTTP verbs to controller actions automatically):
	#   resources :products

	# Sample resource route with options:
	#   resources :products do
	#     member do
	#       get "short"
	#       post "toggle"
	#     end
	#
	#     collection do
	#       get "sold"
	#     end
	#   end

	# Sample resource route with sub-resources:
	#   resources :products do
	#     resources :comments, :sales
	#     resource :seller
	#   end

	# Sample resource route with more complex sub-resources
	#   resources :products do
	#     resources :comments
	#     resources :sales do
	#       get "recent", :on => :collection
	#     end
	#   end

	# Sample resource route within a namespace:
	#   namespace :admin do
	#     # Directs /admin/products/* to Admin::ProductsController
	#     # (app/controllers/admin/products_controller.rb)
	#     resources :products
	#   end

	# You can have the root of your site routed with "root"
	# just remember to delete public/index.html.

	# See how all your routes lay out with "rake routes"

	# This is a legacy wild controller route that"s not recommended for RESTful applications.
	# Note: This route will make all actions in every controller accessible via GET requests.
	# get ":controller(/:action(/:id(.:format)))"
end
