# -*- encoding : utf-8 -*-
# The business logic for the search engine.
#
# Flow:
#  1. User enters query into search box
#  2. suggest() fetches similar search queries for auto-complete
#  3. User presses Enter
#  4. index() saves the query and renders a result view
#  5. The view uses AJAX to load the actual results from fetch()
#  6. fetch() sends query to backends in search/ folder
#  7. The results are inserted into the page
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2013 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

require 'backend/lastfm'

class SearchController < ApplicationController
	respond_to :html, :mobile, :embedded, :json, :xml
	
	include Backend::Lastfm
	
	def index
		redirect_to :action => :index and return if params[:format] == "mobile"
		@query = query_param
		#save_search unless @query.to_s.empty?
		@title = e(params[:q])
		@description = t("index.description")
	end

	def suggest
		q = query_param
		return [] if q.empty?
		
		page = request.referer
		pos = origin_position(request.remote_ip)
		long = pos[:longitude]
		lat = pos[:latitude]
		loc = I18n.locale.to_s
		user = current_user.id if user_signed_in? else -1
		s = Search.suggest(q, page, long, lat, loc, user)
		respond_with(s)
	end
	
	def fetch
		@query = query_param
		@results = { hits: [] }
		respond_with(@results) if @query.to_s.empty?
		@results[:hits].concat Backend::Lastfm.search(@query, category_param)
		
		render json: @results and return
		
		respond_with(@results)
	end
	
	private
	
	def query_param
		q = params[:q] || params[:query] || params[:term] || ""
		CGI::escapeHTML(q)
	end
	
	def category_param
		default = 'artists|songs|devices|playlists|events|albums'
		c = (params[:c] || params[:cat] || params[:categories] || params[:category] || default)
		c.split(/[\|,]/)
	end
	
	def limit_param
		[50, (params[:l] || params[:limit] || "5").to_i].min
	end
	
	def save_search
		begin
			logger.debug "saving query #{query_param}"
			pos = origin_position(request.remote_ip)
			s = Search.new
			s.query = query_param
			s.longitude = pos[:longitude]
			s.latitude = pos[:latitude]
			s.locale = I18n.locale.to_s
			s.categories = category_param
			s.page = request.referer || ""
			s.user = current_user if user_signed_in?
			s.save
		rescue
			logger.error "could not save search for #{query_param}"
		end
	end
	
	def search_artists(results)
		results[:hits] << {
			artist: {
				name: "Bob Dylan",
				image: 'http://userserve-ak.last.fm/serve/_/3008012/Bob+Dylan+dylan.jpg'
			}
		}
		results[:hits] << {
			artist: {
				name: "Bobby Brown",
				image: 'http://userserve-ak.last.fm/serve/_/52207591/Bobby+Brown+png.png'
			}
		}
		results[:exact_artist] = {
			id: 327254663,
			name: 'Bob Marley',
			image: 'http://userserve-ak.last.fm/serve/252/2225962.jpg',
			wikipedia: 'https://en.wikipedia.org/wiki/Bob_marley',
			lastfm: 'http://www.last.fm/music/Bob+Marley',
			listens: '5438',
			url: '/artists/52-bob-marley',
			genres: [
				{
					name: "Reggae",
					url: "foo",
					image: ''
				},
				{
					name: "Ska",
					url: "foo",
					image: ''
				},
			],
			albums: [
				{
					name: "The Wailing Wailers",
					url: "foo",
					image: 'http://userserve-ak.last.fm/serve/_/59214845/The+Wailing+Wailers+o5986961.jpg'
				},
				{
					name: "Exodus",
					url: "foo",
					image: 'http://userserve-ak.last.fm/serve/500/97888555/Exodus.jpg'
				},
				{
					name: "Confrontation",
					url: "foo",
					image: 'http://userserve-ak.last.fm/serve/_/75529450/Confrontation.jpg'
				}
			],
			songs: [
				{
					name: "Jamming",
					url: "foo",
					listens: 13,
				},
				{
					name: "Waiting in Vain",
					url: "foo",
					listens: 8,
				},
				{
					name: "Three Little Birds",
					url: "foo",
					listens: 3,
				}
			],
		}
	end
	
	def search_albums(results)
		results[:hits] << {
			album: {
				name: "Don't Be Cruel",
				image: 'http://userserve-ak.last.fm/serve/300x300/87899689.png',
				artists: [{
					name: "Bobby Brown",
					url: "foo"
				}]
			}
		}
		results[:hits] << {
			album: {
				name: "Gold",
				image: 'http://userserve-ak.last.fm/serve/300x300/40034927.jpg',
				artists: [{
					name: "Bobby Brown",
					url: "foo"
				}]
			}
		}
	end
	
	def search_songs(results)
		results[:hits] << {
			song: {
				name: "Three Little Birds",
				artists: [{
					name: "Bob Marley",
					url: "foo"
				}]
			}
		}
		results[:hits] << {
			song: {
				name: "Like a Rolling Stone",
				artists: [{
					name: "Bob Dylan",
					url: "foo"
				}]
			}
		}
		results[:hits] << {
			song: {
				name: "Every Little Step",
				artists: [{
					name: "Bobby Brown",
					url: "foo"
				}]
			}
		}
	end
	
	def search_playlists(results)
	end
	
	def search_devices(results)
	end
	
	def search_users(results)
	end
	
	def search_events(results)
	end
	
	def search_genres(results)
		results[:hits] << {
			genre: {
				name: "Reggae",
				image: 'http://static.playphone.com/ppbr/pmovil/previews_midias/91757_wap_gif_128x128.gif'
			}
		}
		results[:hits] << {
			genre: {
				name: "Trance",
				image: 'http://edge-img.datpiff.com/m29bdd85/Ricky_J_Broadway_Trance_the_Dubstep_Ep-front.jpg'
			}
		}
		results[:hits] << {
			genre: {
				name: "Hip hop",
				image: 'http://www.yookamusic.com/upload/Playlists/hiphop_128x128.jpg'
			}
		}
		results[:hits] << {
			genre: {
				name: "Death metal",
				image: 'http://image.eveonline.com/Corporation/1039048524_128.png'
			}
		}
	end
end
