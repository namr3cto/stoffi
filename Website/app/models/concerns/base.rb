# -*- encoding : utf-8 -*-
# The common base of all resource models.
#
# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2013 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

# A base for all resources.
#
# TODO: should we inject this into the inheritance
#       hiearchy instead?
module Base
	extend ActiveSupport::Concern
	
	# What to print when cast to a string.
	alias_attribute :to_s, :display

	# The type of the resource.
	# TODO: alias?
	def kind
		self.class.name.downcase
	end

	# The base URL for all resources.
	# TODO: remove?
	def base_url
		"http://beta.stoffiplayer.com"
	end
	
	# The URL of the resource.
	# TODO: fix?
	def url
		"#{base_url}/#{kind.pluralize}/#{id}"
	end
	
	# The path to use when creating links using <tt>url_for</tt> to the resource.
	# TODO: pretty-ids?
	def to_param
		if display.blank?
			id.to_s
		else
			"#{id}-#{display.parameterize}"
		end
	end

	# The options to use when serializing the resource.
	# TODO: remove?
	def serialize_options
		{
			methods: [ :kind, :display, :url ]
		}
	end
	
	# Serializes the resource to JSON.
	# TODO: remove?
	def as_json(options = {})
		super(DeepMerge.deep_merge!(serialize_options, options))
	end
	
	# Serializes the resource to XML.
	# TODO: remove?
	def to_xml(options = {})
		super(DeepMerge.deep_merge!(serialize_options, options))
	end
	
	# Cleans a string so it can be safely stored and transmitted.
	# TODO: remove!
	def e(str)
		self.class.e(str)
	end
	
	# Decode a string for presentation.
	# TODO: remove!
	def d(str)
		self.class.d(str)
	end
	
	module ClassMethods
	
		def find_or_create_by_hash(hash)
			validate_hash(hash)
			name = hash[:name].titleize
			o = find_by(name: name) || create(name: name)
			raise "Could neither find nor create instance named #{name}" unless o
			o.images << Image.create_by_hashes(hash[:images]).reject { |i| o.images.include? i } if hash.key? :images
			o
		end
	
		private
	
		def validate_hash(hash)
			raise "Missing name in hash" unless hash.key? :name
		end

		# Decode a string for presentation.
		# TODO: remove!
		def d(str)
			return str unless str.is_a? String
		
			next_str = HTMLEntities.new.decode(str)
			while (next_str != str)
				str = next_str
				next_str = HTMLEntities.new.decode(str)
			end
			return next_str
		end

		# Encodes a string so it can be stored and transmitted.
		#
		# The string is first decoded until it doesn't change
		# anything and then a single encoding is performed.
		# TODO: remove!
		def e(str)
			return unless str
		
			if str.is_a? String
				str = HTMLEntities.new.encode(d(str), :decimal)
				str.gsub!(/[']/, "&#39;")
				str.gsub!(/["]/, "&#34;")
				str.gsub!(/[\\]/, "&#92;")
				return str
			end
		
			return str.map { |s| e(s) } if str.is_a?(Array)
			return str.each { |a,b| str[a] = e(b) } if str.is_a?(Hash)
			return str
		end
		
	end
end
