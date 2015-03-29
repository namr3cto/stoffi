# -*- encoding : utf-8 -*-
# The business logic for the search engine.
#
# Flow:
#  1. User enters query into search box
#  2. suggest() fetches similar search queries for auto-complete
#  3. User presses Enter
#  4. index() saves the query and renders a skeleton result view
#  5. The view uses AJAX to load the actual results from fetch()
#  6. fetch() sends query to backends in search/ folder
#  7. The results are injected into the page
#
# For API calls the index() method will directly fetch results
# and return them.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2013 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

#require 'backend/lastfm'
#require 'backend/youtube'
#require 'backend/soundcloud'

class SearchController < ApplicationController

	def suggest
		@query = query_param
		@suggestions = []
		if @query.present?
			page = request.referer
			pos = origin_position(request.remote_ip)
			long = pos[:longitude]
			lat = pos[:latitude]
			loc = I18n.locale.to_s
			user = user_signed_in? ? current_user.id : -1
			@suggestions = Search.suggest(@query, page, long, lat, loc, user)
		end
		render @suggestions
	end
	
	def index
		@search = save_search
		@query = query_param
		@categories = category_param
		@sources = source_param
		@title = e(@query)
		@description = t("index.description")
		
		respond_to do |format|
			format.html { render @search }
			format.js { @results = @search.do(page_param, limit_param) }
			format.json { render json: @search.do(page_param, limit_param) }
		end
	end
	
	def fetch
		@search = Search.find(params[:id])
		head :unprocessable_entity and return if @search.query.blank?
		@results = @search.do(page_param, limit_param)
		@paginatable_array = Kaminari.paginate_array(@results[:hits], total_count: @results[:total_hits])
			.page(page_param).per(limit_param)
		render @results, layout: false
	end
	
	private
	
	def query_param
		q = params[:q] || params[:query] || params[:term] || ""
		CGI::escapeHTML(q)
	end
	
	def category_param
		x = params[:c] || params[:cat] || params[:categories] || params[:category]
		x ? x.split(/[\|,]/) : Search.categories
	end
	
	def source_param
		x = params[:s] || params[:src] || params[:sources] || params[:source]
		x ? x.split(/[\|,]/) : Search.sources
	end
	
	def limit_param
		[50, (params[:limit] || "20").to_i].min
	end
	
	def page_param
		(params[:p] || params[:page] || "1").to_i
	end
	
	# Save a search
	#
	# This is later used for auto-complete suggestions, and
	# for knowing when a cache is dirty
	def save_search
		pos = origin_position(request.remote_ip)
		s = Search.new
		s.query = query_param
		s.longitude = pos[:longitude]
		s.latitude = pos[:latitude]
		s.locale = I18n.locale.to_s
		s.categories = category_param.sort.join('|')
		s.sources = source_param.sort.join('|')
		s.page = request.referer || ""
		s.user = current_user if user_signed_in?
		s.save
		s
	end
end
