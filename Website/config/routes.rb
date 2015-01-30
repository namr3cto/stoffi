# -*- encoding : utf-8 -*-
Stoffi::Application.routes.draw do

	scope '(:l)', l: /us|uk|se|cn|de/ do

		namespace :admin do
			resources :translatees
			resources :translatee_params
			resources :configs
		end
		
		as :user do
			get    'login',         to: 'users/sessions#new',            as: :new_user_session
			post   'login',         to: 'users/sessions#create',         as: :user_session
			delete 'logout',        to: 'users/sessions#destroy',        as: :destroy_user_session
			get    'logout',        to: 'users/sessions#destroy'
			
			post   'forgot',        to: 'users/passwords#create',        as: :user_password
			get    'forgot',        to: 'users/passwords#new',           as: :new_user_password
			get    'reset',         to: 'users/passwords#edit',          as: :edit_user_password
			patch  'reset',         to: 'users/passwords#update'
			put    'reset',         to: 'users/passwords#update'
			
			get    'cancel',        to: 'users/registrations#cancel',    as: :cancel_user_registration
			post   'join',          to: 'users/registrations#create',    as: :user_registration
			get    'join',          to: 'users/registrations#new',       as: :new_user_registration
			get    'settings',      to: 'users/registrations#edit',      as: :edit_user_registration
			patch  'settings(/:id)', to: 'users/registrations#update',    as: :update_user_registration
			put    'settings(/:id)', to: 'users/registrations#update'
			delete 'leave',         to: 'users/registrations#destroy',   as: :leave
			
			post   'unlock',        to: 'users/unlocks#create',          as: :user_unlock
			get    'unlock',        to: 'users/unlocks#new',             as: :new_user_unlock
			
			get    'profile(/:id)', to: 'users/registrations#show',      as: :user
			get    'dashboard',     to: 'users/registrations#dashboard', as: :dashboard
			
			get    'me/playlists',  to: 'playlists#by'
			get    'me',            to: 'users/registrations#show',      as: :me
			get    'profile(/:user_id)/playlists', to: 'playlists#by'
			
			# handle failed omniauth
			get    'auth/failure',  to: 'users/sessions#new'
		end
		
		devise_for :user, skip: :all, controllers:
		{
			registrations: 'users/registrations',
			sessions: 'users/sessions',
			passwords: 'users/passwords',
			unlocks: 'users/unlocks'
		}

		get 'youtube/:action' => 'youtube'
		
		# charts
		namespace :charts do
			get 'recent_listens_for_user'
			get 'active_users'
		end
		
		get '/news',       to: 'pages#news',       as: :news
		get '/tour',       to: 'pages#tour',       as: :tour
		get '/get',        to: 'pages#get',        as: :get
		get '/download',   to: 'pages#download',   as: :download
		get '/checksum',   to: 'pages#checksum',   as: :checksum
		get '/contact',    to: 'pages#contact',    as: :contact
		get '/about',      to: 'pages#about',      as: :about
		get '/legal',      to: 'pages#legal',      as: :legal
		get '/money',      to: 'pages#money',      as: :money
		get '/remote',     to: 'pages#remote',     as: :remote
		get '/history',    to: 'pages#history',    as: :history
		get '/language',   to: 'pages#language',   as: :lang
		get '/donate',     to: 'pages#donate',     as: :donate
		get '/mail',       to: 'pages#mail',       as: :mail
		get '/facebook',   to: 'pages#facebook',   as: :facebook
		get '/channel',    to: 'pages#channel',    as: :facebook_channel
		get '/old',        to: 'pages#old',        as: :old
		get '/foo',        to: 'pages#foo',        as: :foo

		resources :translations, :languages, :votes, :devices
		resources :oauth_clients, path: 'apps', as: :client_application
		resources :oauth_clients, path: 'apps', as: :oauth_clients
		resources :oauth_clients, path: 'apps', as: :apps do
			member do
				delete 'revoke'
			end
		end
		
		resources :links, only: [:index, :show, :create, :update, :destroy]
		
		resources :artists, :events, :songs, :genres, :albums do
			collection do
				get 'weekly'
			end
		end
		
		resources :listens do
			member do
				post 'end'
			end
		end
		
		resources :playlists do
			member do
				put 'follow'
			end
			collection do
				get 'weekly'
				get '/by/:user_id', to: 'playlists#by'
			end
		end
		
		resources :shares do
			collection do
				get '/by/:user_id', to: 'shares#by'
			end
		end
		
		resources :donations do
			collection do
				get '/by/:user_id', to: 'donations#by'
			end
		end
		
		resources :configurations do
			member do
				post 'next'
				post 'prev'
				put 'play'
				put 'pause'
				post 'play_pause', path: 'play-pause'
			end
		end

		get   '/oauth/test_request',      to: 'oauth#test_request',      as: :test_request
		get   '/oauth/token',             to: 'oauth#token',             as: :token
		post  '/oauth/access_token',      to: 'oauth#access_token',      as: :access_token
		post  '/oauth/request_token',     to: 'oauth#request_token',     as: :request_token
		match '/oauth/authorize',         to: 'oauth#authorize',         as: :authorize, via: [:get, :post]
		get   '/oauth/revoke',            to: 'oauth#revoke',            as: :revoke
		get   '/oauth',                   to: 'oauth#index',             as: :oauth
		
		get '/auth/:provider/callback',   to: 'links#create'

		get '/search/suggest'
		get '/search/fetch'
		get '/search/(:categories)',      to: 'search#index',            as: :search
		
	
		get '/', to: 'pages#index', as: :root
	end
end
