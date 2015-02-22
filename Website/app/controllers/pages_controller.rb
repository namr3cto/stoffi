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
	
	respond_to :html, :mobile, :embedded, :json, :xml
	
	def foo
	end

	def old
		render layout: 'empty'
	end
	
	def index
		redirect_to dashboard_url and return if params[:format] == :embedded
		render layout: 'fullwidth'
	end

	def news
	end

	def get
	end

	def download
		params[:channel] ||= "stable"
		params[:arch] ||= "32"
		
		verify_channel
		verify_arch
		
		@filename = download_filename
		@path = "/downloads/" + params[:channel] + "/" + params[:arch] + "bit/" + @filename + '.exe'
		@url = request.protocol + request.host_with_port + @path
	end
	
	def checksum
		params[:channel] ||= "stable"
		params[:arch] ||= "32"
		
		verify_channel
		verify_arch
		
		@filename = download_filename
		@path = "/downloads/" + params[:channel] + "/" + params[:arch] + "bit/" + @filename + '.sum'
		@url = request.protocol + request.host_with_port + @path
	end

	def tour
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
			SystemMailer.contact(domain: "beta.stoffiplayer.com",
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
	
	def download_filename
		filename = "InstallStoffi"
		filename = "InstallStoffiAlpha" if params[:channel] == "alpha"
		filename = "InstallStoffiBeta" if params[:channel] == "beta"
		filename += "AndDotNet" if params[:fat] && params[:fat] == "1"
		filename
	end

	def verify_channel
		unless ["alpha", "beta", "stable"].include? params[:channel]
			redirect_to "/get" and return
		end
	end
	
	def verify_arch
		unless ["32", "64"].include? params[:arch]
			redirect_to "/get" and return
		end
	end
end
