# The business logic for events.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::      Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::   Copyright (c) 2015 Simplare
# License::     GNU General Public License (stoffiplayer.com/license)

class EventsController < ApplicationController
	
	before_action :set_event, only: [:show, :edit, :update, :destroy]
	before_action :ensure_admin, only: [ :update, :destroy ]
	oauthenticate interactive: true, except: [ :index, :show ]

	# GET /events
	def index
		l, o = pagination_params
		pos = origin_position(request.remote_ip)
		pos = [pos[:longitude], pos[:latitude]]
		@popular = Event.upcoming.order(:start).limit(l).offset(o)
		@close = Event.upcoming.by_distance(origin: pos).limit(l).offset(o).order(:start)
		
		if user_signed_in?
			artist_ids = []
			artists = Artist.top(for: current_user, from: 7.days.ago).limit(l)
			artists.each { |a| artist_ids << a.id }
			where_clause = artist_ids.map { |id| "performances.artist_id = #{id}" }.join(' OR ')
			@user_popular = Event.upcoming.joins(:artists).where(where_clause).uniq.limit(l).offset(o)
		end
	end

	# GET /events/1
	def show
	end

	# POST /events
	def create
		@event = Event.new(event_params)

		respond_to do |format|
			if @event.save
				format.html { redirect_to @event, notice: 'Event was successfully created.' }
				format.json { render :show, status: :created, location: @event }
			else
				format.html { render :new }
				format.json { render json: @event.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /events/1
	def update
		respond_to do |format|
			if @event.update(event_params)
				format.html { redirect_to @event, notice: 'Event was successfully updated.' }
				format.json { render :show, status: :ok, location: @event }
			else
				format.html { render :edit }
				format.json { render json: @event.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /events/1
	def destroy
		@event.destroy
		respond_to do |format|
			format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
			format.json { head :no_content }
		end
	end

	private
	
	# Use callbacks to share common setup or constraints between actions.
	def set_event
		not_found('event') and return unless Event.exists? params[:id]
		@event = Event.find(params[:id])
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def event_params
		params.require(:event).permit(:name, :venue, :latitude, :longitude, :start, :stop, :content, :category)
	end
end
