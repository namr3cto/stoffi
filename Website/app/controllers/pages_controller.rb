# -*- encoding : utf-8 -*-
# The business logic for the main pages of the website (non-resources).
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2013 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

class PagesController < ApplicationController
	oauthenticate only: [ :remote ]
	
	before_filter :set_title_and_description
	respond_to :html, :mobile, :embedded, :json, :xml
	
	def foo
	end

	def old
		render layout: false
	end
	
	def index
		redirect_to dashboard_url if params[:format] == :embedded
	end

	def news
	end

	def get
	end

	def download
		params[:channel] = "stable" unless params[:channel]
		params[:arch] = "32" unless params[:arch]
		@type = params[:type] || "installer"
		
		unless ["alpha", "beta", "stable"].include? params[:channel]
			redirect_to "/get" and return
		end
		
		unless ["32", "64"].include? params[:arch]
			redirect_to "/get" and return
		end
		
		unless ["installer", "checksum"].include? @type
			redirect_to "/get" and return
		end
		
		filename = "InstallStoffi"
		filename = "InstallStoffiAlpha" if params[:channel] == "alpha"
		filename = "InstallStoffiBeta" if params[:channel] == "beta"
		
		filename += "AndDotNet" if params[:fat] && params[:fat] == "1"
		
		@fname = filename
		
		filename += case @type
			when "checksum" then ".sum"
			else ".exe"
		end
		
		@file = "/downloads/" + params[:channel] + "/" + params[:arch] + "bit/" + filename
		@autodownload = @type == "installer"
	end

	def tour
		redirect_to action: :index and return if params[:format] == "mobile"
	end

	def about
	end

	def contact
	end

	def legal
	end

	def money
	end

	def history
		redirect_to "http://dev.stoffiplayer.com/wiki/History"
	end

	def remote
	
		if current_user and current_user.configurations.count > 0 and current_user.configurations.first.devices.count > 0
			@configuration = current_user.configurations.first
			
			@devices = @configuration.devices.order(:name)
		end
		
		@title = t("remote.title")
		@description = t("remote.description")
		
		render "configurations/show", layout: (params[:format] != "mobile" ? true : 'empty')
	end

	def language
		respond_to do |format|
			format.html { redirect_to root_url }
			format.mobile { render }
		end
	end

	def donate
		logger.info "redirecting donate shortcut"
		respond_with do |format|
			format.html { redirect_to donations_url, flash: flash }
			format.mobile { redirect_to new_donation_url, flash: flash }
		end
	end
  
	def mail				
		if !params[:name] or params[:name].length < 2
				flash[:error] = t("contact.errors.name")
				render action: 'contact'
				
		elsif !params[:email] or params[:email].match(/^([a-z0-9_.\-]+)@([a-z0-9\-.]+)\.([a-z.]+)$/i).nil?
				flash[:error] = t("contact.errors.email")
				render action: 'contact'
				
		elsif !params[:subject] or params[:subject].length < 4
				flash[:error] = t("contact.errors.subject") 
				render action: 'contact'
				
		elsif !params[:message] or params[:message].length < 20
				flash[:error] = t("contact.errors.message")
				render action: 'contact'

		elsif !verify_recaptcha
			flash[:error] = t("contact.errors.captcha")
			render action: 'contact'
			
		else
			Mailer.contact(domain: "beta.stoffiplayer.com",
			               subject: params[:subject],
			               from: params[:email],
			               name: params[:name],
			               message: params[:message]).deliver
			redirect_to action: 'contact', sent: 'success'
		end
	end

	def facebook
		render layout: "facebook"
	end

	def channel
		render layout: false
	end
	
	private
	
	def set_title_and_description
		@title = t("#{action_name}.title")
		@description = t("#{action_name}.description")
	end

end
