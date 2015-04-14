# -*- encoding : utf-8 -*-
# The model of the app resource.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2013 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

require 'oauth'
require 'base'

# Describes an app for accessing the API.
class ClientApplication < ActiveRecord::Base
	include Base
	
	# associations
	belongs_to :user
	with_options dependent: :destroy do |assoc|
		assoc.has_many :tokens, class_name: "OauthToken"
		assoc.has_many :access_tokens
		assoc.has_many :oauth2_verifiers
		assoc.has_many :oauth_tokens
	end
	
	has_many :users, through: :access_tokens
	
	# validations
	validates_presence_of :name, :website, :key, :secret
	validates_uniqueness_of :key
	before_validation :generate_keys, on: :create

	validates_format_of :website, with: /\Ahttp(s?):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i
	validates_format_of :support_url, with: /\Ahttp(s?):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i, :allow_blank=>true
	validates_format_of :callback_url, with: /\Ahttp(s?):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i, :allow_blank=>true

	attr_accessor :token_callback_url
	
	searchable do
		text :name, :author, :description
	end
	
	# Gets a list of all apps not added by a given user
	def self.not_added_by(user)
		if user == nil
			return self.all
		else
			# TODO: clean up
			tokens = "SELECT * from oauth_tokens WHERE oauth_tokens.invalidated_at IS NULL AND oauth_tokens.authorized_at IS NOT NULL AND oauth_tokens.user_id = #{user.id}"
		
			return select("client_applications.*").
			joins("LEFT JOIN (#{tokens}) oauth_tokens ON oauth_tokens.client_application_id = client_applications.id").
			group("client_applications.id").
			having("count(oauth_tokens.id) = 0")
		end
	end

	# Gets an authorized token given a token key.
	def self.find_token(token_key)
		token = OauthToken.find_by(token: token_key, include: :client_application)
		if token && token.authorized?
			token
		else
			nil
		end
	end

	# Verifies a request by signing it with OAuth.
	def self.verify_request(request, options = {}, &block)
		begin
			signature = OAuth::Signature.build(request, options, &block)
			return false unless OauthNonce.remember(signature.request.nonce, signature.request.timestamp)
			value = signature.verify
			value
		rescue OAuth::Signature::UnknownSignatureMethod => e
			false
		end
	end
	
	def self.rank
		self.select("client_applications.*,COUNT(DISTINCT(users.id)) AS user_count").
			joins("LEFT JOIN oauth_tokens ON oauth_tokens.client_application_id = client_applications.id").
			joins("LEFT JOIN users ON oauth_tokens.user_id = users.id").
			group("client_applications.id").order("user_count DESC")
	end
	
	def self.permissions
		["name", "picture", "playlists", "listens", "shares"]
	end

	# The URL to the OAuth server.
	def oauth_server
		@oauth_server ||= OAuth::Server.new("http://beta.stoffiplayer.com")
	end

	# The credentials of the OAuth consumer.
	def credentials
		@oauth_client ||= OAuth::Consumer.new(key, secret)
	end

	# Creates a token for requesting access to the OAuth API.
	#
	# Note: If our application requires passing in extra parameters handle it here
	def create_request_token(params={})
		RequestToken.create client_application: self, callback_url: self.token_callback_url
	end
	
	def image(size = :huge)
		sizes = {
			tiny: 16,
			small: 32,
			medium: 64,
			large: 128,
			huge: 512
		}
		raise "Invalid icon size: #{size}" unless size.in? sizes
		m = "icon_#{sizes[size]}"
		return send(m) if respond_to?(m) and send(m).present?
		"gfx/icons/#{sizes[size]}/app.png"
	end
	
	def similar
		search = ClientApplication.search do
			fulltext name.split.join(' or ') do
				phrase_fields name: 5.0
				phrase_slop 2
			end
		end
		search.results
	end
	
	def installed_by?(user)
		return false unless user
		tokens.valid.where(user: user).count > 0
	end
	
	# The type of the resource.
	def kind
		"app"
	end
	
	# The string to display to users for representing the resource.
	def display
		name
	end
	
	# The options to use when the app is serialized.
	def serialize_options
		{
			except: :secret,
			methods: [ :kind, :display, :url ]
		}
	end

	protected

	# Generate the public and secret API keys for the app.
	def generate_keys
		self.key = OAuth::Helper.generate_key(40)[0,40]
		self.secret = OAuth::Helper.generate_key(40)[0,40]
	end
end
