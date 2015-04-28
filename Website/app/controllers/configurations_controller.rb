# -*- encoding : utf-8 -*-
# The business logic for synchronization configurations.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2015 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

class ConfigurationsController < ApplicationController

	oauthenticate
	before_action :set_config, only: [:show, :update, :destroy, :next, :prev, :play,
		:pause, :play_pause]

	# GET /configurations/1
	def show
		respond_to do |format|
			format.html { redirect_to remote_path }
			format.json { render }
		end
	end

	# POST /configurations
	def create
		@config = current_user.configurations.new(config_params)
		success = @config.save
		SyncController.send('create', @config, request) if success
		respond_to do |format|
			if success
				format.html { redirect_to @config, notice: 'Configuration was successfully created.' }
				format.json { render :show, status: :created, location: @config }
			else
				format.html { render dashboard_path }
				format.json { render json: @config.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH /configurations/1
	def update
		song = nil
		if config_params[:current_track]
			song = Song.get(current_user, config_params[:current_track])
			config_params[:current_track_id] = song.id if song.is_a?(Song)
			config_params.delete(:current_track)
		end
		success = @config.update_attributes(config_params)
		config_params[:now_playing] = song.full_name if song.is_a?(Song)
		SyncController.send('update', @config, request, config_params) if success
		respond_to do |format|
			if success
				format.html { redirect_to @config, notice: 'Configuration was successfully updated.' }
				format.json { render :show, status: :ok, location: @config }
			else
				format.html { render :show }
				format.json { render json: @config.errors, status: :unprocessable_entity }
			end
		end
	end
	
	# PUT /configurations/1/next
	def next
		SyncController.send('execute', @config, request, 'next')
	end
	
	# PUT /configurations/1/prev
	def prev
		SyncController.send('execute', @config, request, 'prev')
	end
	
	# PUT /configurations/1/play-pause
	def play_pause
		SyncController.send('execute', @config, request, 'play-pause')
	end
	
	# PUT /configurations/1/play
	def play
		SyncController.send('execute', @config, request, 'play')
	end
	
	# PUT /configurations/1/pause
	def pause
		SyncController.send('execute', @config, request, 'pause')
	end
	
	private
	
	# Use callbacks to share common setup or constraints between actions.
	def set_config
		not_found('config') and return unless current_user.configurations.exists? params[:id]
		@config = current_user.configurations.find(params[:id])
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def config_params
		params.require(:configuration).permit(:name, :media_state, :shuffle, :repeat,
			:current_track)
	end
end
