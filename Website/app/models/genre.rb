# -*- encoding : utf-8 -*-
# The model of the genre resource.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2014 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

# Describes a genre, defining (loosely) a musical style.
class Genre < ActiveRecord::Base
	include Base
	include Imageable
	include Sourceable
	
	has_and_belongs_to_many :songs, uniq: true
	with_options through: :songs do |assoc|
		assoc.has_many :artists
		assoc.has_many :albums
	end
	
	validates :name, presence: true
	
	searchable do
		text :name
		string :locations, multiple: true do
			sources.map(&:name)
		end
	end
	
	def display
		name
	end
end
