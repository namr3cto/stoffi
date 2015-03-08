# The duplicatable concern.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2013 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)
#

# Use this concern to allow a model to have duplicates.
#
# = Examples
#
# Mark a as a duplicate of b:
#   a.duplicate_of b
#
# Get the original, given a duplicate:
#   b.archetype # returns b
#
# By default, relations will filter out any duplicates:
#
#   artist.songs.count # returns 5
#   artist.songs.first.duplicate_of artist.songs.last
#   artist.songs.count # returns 4
#
# You have unscope the relation to include duplicates:
#
#   artist.songs.unscoped.count # returns 5
#
# Duplicates are recursive:
#
#   a.duplicate_of b
#   b.duplicate_of c
#   a.archetype # returns c
#
# Combine associations:
#
#   class Person
#     has_many :hobbies
#     include_association_of_dups
#   end
#
# Now `alice.hobbies` will include `bob.hobbies` if you set `bob.duplicate_of alice`.
#
# = Setup
#
# You need to add a migration to your model in order to use
# this concern:
#   rails g migration AddArchetypeToMODEL archetype:references{polymorphic}
#   rake db:migrate
#
module Duplicatable
	extend ActiveSupport::Concern
	
	included do
		has_many :duplicates, as: :archetype, class_name: self.name
		belongs_to :archetype, polymorphic: true
	end
	
	# Mark as a duplicate of another resource
	def duplicate_of(resource)
		if self.class != resource.class
			raise TypeError.new("Cannot mark a #{resource.class.name} as duplicate of a #{self.class.name}")
		end
		self.archetype = resource
		save
	end
	
	def duplicate_of?(resource)
		self.archetype == resource
	end
	
	# Get the archetype (original) of a duplicate
	# Returns itself if it's not marked as a duplicate
	def archetype
		super ? super.archetype : self
	end
	
	# Check if the record is marked as a duplicate
	def duplicate?
		archetype != self
	end
	
	# Returns only duplicates directly under this resource
	def direct_duplicates
		self.class.unscope.where(archetype: self)
	end
	
	# Returns all duplicates of this resource
	def duplicates
		w = ''
		ids = [id]
		children = self.class.unscoped.where(archetype: self)
		i = 0
		while i < children.size
			child = children[i]
			ids << child.id
			children += self.class.unscoped.where(archetype: child)
			i+=1
		end
		ids.map! { |x| "archetype_id=#{x}" }
		ids = ids.join ' or '
		ids = " and (#{ids})" if ids.present?
		w = "archetype_type = '#{self.class.name}' #{ids}"
		self.class.unscoped.where(w)
	end
	
	module ClassMethods
		
		# Filter out duplicates by default
		def default_scope
			where(archetype: nil)
		end
		
		# Include associations of all duplicates when accessing an association.
		#
		# When you access the association on an archetype, it will include the
		# associations on all its duplicates as well.
		#
		# Put this into your class after your associations:
		#   include_association_of_dups
		#
		# Turn on for specific assocations:
		#   include_association_of_dups :comments, :tags
		# This is the same as:
		#   include_association_of_dups only: [:comments, :tags]
		#
		# You can also use blacklisting:
		#   include_association_of_dups except: :authors
		#
		def include_associations_of_dups(*associations)
			associations << {except: []} if associations.empty?
			unless associations[0].is_a? Hash
				associations = [{only: associations}]
			end
			associations = build_associations_from_hash associations[0]
			
			# override each association method
			associations.each do |name|
				next unless valid_association_for_combining?(name)
				define_method name do |*arguments|
					return super(arguments) if duplicates.empty?
		
					w = [] # where clause
					type, key, tbl = self.get_sql_names_for_combining name, self.class.reflections[name]
			
					# do we need to specify the resource type? (if polymorphic, for example)
					w << "#{tbl}.#{type}='#{self.class.name}'" if type.present?

					# get the IDs of each duplicate, and self
					ids = [id] + duplicates.map(&:id)
					ids.map! { |i| "#{tbl}.#{key}=#{i}" }
					w << "(#{ids.join(' or ')})" if ids.size > 0

					wsql = w.join ' and '
		
					# construct relation
					r = association(name).reader(arguments).unscope(where: key).where(wsql)
					self.class.reflections[name].options[:uniq] ? r.uniq : r
				end
			end
		end
		
		private
		
		# Validate that all associations can be combined
		def validate_associations_for_combining(associations)
			associations.each do |name|
				unless reflections.key? name
					raise ArgumentError.new("No such association: #{name}")
				end
				unless valid_association_for_combining?(name)
					raise ArgumentError.new("Association type not allowed: #{reflection[name].macro}")
				end
			end
		end
		
		# Check if a association can be combined
		def valid_association_for_combining?(name)
			reflections[name].macro.in? [:has_and_belongs_to_many, :has_many]
		end
		
		# Build a list of associations from an argument hash
		def build_associations_from_hash(association_hash)
			if association_hash.key? :only
				associations = association_hash[:only]
				validate_associations_for_combining associations
			elsif association_hash.key? :except
				assocations = reflections.keys - association_hash[:except]
			else
				raise ArgumentError.new("Argument hash contains neither :only nor :except key")
			end
		end
		
	end
	
	protected

	# Get the table name, foreign key and foreign type used to construct
	# a where clause when combining associations.
	def get_sql_names_for_combining(name, reflection)
		if reflection.macro == :has_many and reflection.options.key? :through
			r = self.class.reflections[reflection.options[:through]]
			return get_sql_names_for_combining(name, r)
			
		elsif reflection.macro == :has_and_belongs_to_many
			type = reflection.type
			key = reflection.foreign_key
			tbl = reflection.join_table
			
		else
			type = reflection.type
			key = reflection.foreign_key
			tbl = reflection.quoted_table_name
		end
		return type, key, tbl
	end
	
end