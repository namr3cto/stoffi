# -*- encoding : utf-8 -*-
# The business logic for devices.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2013 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

class DevicesController < ApplicationController

	oauthenticate
	before_action :set_device, only: [:show, :update, :destroy]
	before_action :ensure_owner_or_admin, only: [:show, :update, :destroy]
	
	# GET /devices
	def index
		l, o = pagination_params
		@devices = current_user.devices.limit(l).offset(o)
	end

	# GET /devices/1
	def show
		@device.update_attribute :last_ip, '81.226.15.69'
	end

	# POST /devices
	def create
		@device = current_user.devices.new(device_params)
		success = @device.save
		
		if success
			@device.poke(current_client_application, request.ip)
			SyncController.send('create', @device, request)
		end
		
		respond_to do |format|
			if success
				format.html { redirect_to @device, notice: 'Device was successfully created.' }
				format.json { render :show, status: :created, location: @device }
			else
				format.html { render :new }
				format.json { render json: @device.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH /devices/1
	def update
		success = @device.update(device_params)
		SyncController.send('update', @device, request) if success
		respond_to do |format|
			if success
				format.html { redirect_to @device, notice: 'Device was successfully updated.' }
				format.json { render :show, status: :ok, location: @device }
			else
				format.html { render :edit }
				format.json { render json: @device.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /devices/1
	def destroy
		SyncController.send('delete', @device, request)
		@device.destroy
		respond_to do |format|
			format.html { redirect_to devices_url, notice: 'Device was successfully destroyed.' }
			format.json { head :no_content }
		end
	end
	
	private
	
	# Use callbacks to share common setup or constraints between actions.
	def set_device
		not_found('device') and return unless Device.exists? params[:id]
		@device = Device.find(params[:id])
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def device_params
		params.require(:device).permit(:name, :version)
	end
	
	def ensure_owner_or_admin
		access_denied unless current_user.owns?(@device) or current_user.admin?
	end
end
