# -*- encoding : utf-8 -*-
# The business logic for session of logged in users.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2013 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

class Users::SessionsController < Devise::SessionsController
	layout 'fullwidth'
	
	def new
		#flash[:alert] = nil
		if request.referer && ![user_session_url, user_registration_url, user_unlock_url, user_password_url].index(request.referer)
			session["user_return_to"] = request.referer
		end
		super
	end
end
