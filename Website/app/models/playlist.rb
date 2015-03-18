# -*- encoding : utf-8 -*-
# The model of the playlist resource.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2013 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

require 'base'
class Playlist < ActiveRecord::Base
	include Base
	include Rankable
	include Sourceable
	include Followable

	has_and_belongs_to_many :songs, uniq: true do
		def page(limit=25, offset=0)
			all(limit: limit, offset: offset)
		end
	end
	
	has_many :listens, through: :songs
	has_many :artists, through: :songs
	has_many :shares, as: :object
	belongs_to :user
	has_many :link_backlogs, as: :resource, dependent: :destroy
	
	validates :name, presence: true
	validates :user, presence: true
	validates :name, uniqueness: { scope: :user_id, case_sensitive: false }
	
	followable_by User
	
	searchable do
		text :name, boost: 5
		text :artists do
			artists.map(&:name)
		end
		text :songs do
			songs.map(&:title)
		end
		string :locations, multiple: true do
			sources.map(&:name)
		end
	end
	
	def display
		name
	end
	
	def image(size = :huge)
		"gfx/icons/256/playlist.png"
		#songs.count == 0 ? "/assets/media/disc.png" : songs.first.picture
	end
	
	def play
		"stoffi:playlist:#{id}"
	end
	
	def paginate_songs(limit, offset)
		@paginated_songs = Array.new
		songs.limit(limit).offset(offset).each do |song|
			@paginated_songs << song
		end
	end
	
	def paginated_songs
		return @paginated_songs
	end
	
	def dynamic?
		filter.present?
	end
	
	def self.get(current_user, value)
		value = current_user.playlists.find(value) if value.is_a?(Integer)
		value = current_user.playlists.find_or_create_by(name: value) if value.is_a?(String)
		return value if value.is_a?(Playlist)
		return nil
	end
	
	def self.top(limit = 5, offset = 0, user = nil)
		self.select("playlists.id, playlists.name, playlists.is_public, playlists.user_id, count(listens.id) AS listens_count").
		joins("LEFT JOIN listens ON listens.playlist_id = playlists.id").
		where("listens.user_id IS NULL" + (user == nil ? "" : " or listens.user_id = #{user.id}")).
		where(user == nil ? "playlists.is_public" : "playlists.user_id = #{user.id}").
		group("playlists.id").
		order("listens_count DESC, playlists.updated_at DESC").
		limit(limit).
		offset(offset)
	end
	
	def self.is_public
		where(is_public: 1)
	end
	
	def self.search(user, search, limit = 5, offset = 0)
		if search
			search = e(search)
			w = user == nil ? "" : "or user_id = #{user.id}"
			self.where("name LIKE ? and (is_public = 1 #{w})", "%#{search}%").
			limit(limit).
			offset(offset)
		else
			scoped
		end
	end
end
