# The followable concern.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2015 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)
#

# Use this concern to allow a model to follow other resources.
#
# See Followable for details.
module Followingable
	extend ActiveSupport::Concern
	
	included do
		has_many :followings, as: :follower, dependent: :destroy
	end
	
	# Returns an array of the resources that is being followed
	def follows
		followings.map(&:followee)
	end
	
	# Returns an array of the resources of a specific type
	# that are being followed.
	def following(class_name)
		followings.where(followee_type: class_name).map(&:followee)
	end
	
	# Check if the user follows a given resource
	def follows?(resource)
		self.in? resource.followers
	end
	
	# Follow a resource
	def follow(resource)
		
		# check if self is owner to resource
		[self.class.name.underscore, :owner].each do |method|
			if resource.respond_to? method
				if resource.send(method) == self
					raise "Cannot follow #{resource} since it belongs to #{self}"
				end
				break
			end
		end
		
		Following.create(
			follower: self,
			followee: resource
		)
	end
	
	# Unfollow a resource
	def unfollow(resource)
		followings.where(followee: resource).destroy_all
	end
end