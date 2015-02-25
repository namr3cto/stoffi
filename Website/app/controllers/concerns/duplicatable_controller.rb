module DuplicatableController
	extend ActiveSupport::Concern
	
	module ClassMethods
	
		# Specify a class as duplicatable.
		#
		# This will cause the controller to automatically redirect show
		# requests for the model to its archetype, and allow update/create
		# requests to specify :archetype 
		def can_duplicate(resource)
			@duplicatable_model = resource
			before_filter :redirect_duplicates, only: [:show]
			before_filter :parse_duplicate_params, only: [:update, :create]
		end
		
		def duplicatable_model
			@duplicatable_model
		end
		
	end
	
	private
	
	# Automatically redirect to a resource's archetype if it has one
	def redirect_duplicates
		resource = self.class.duplicatable_model.unscoped.find(params[:id])
		redirect_to resource.archetype and return if resource.duplicate?
	end
	
	# Look for :archetype in params and change it from an ID as string, to
	# a real object.
	def parse_duplicate_params
		resource_key = self.class.duplicatable_model.to_s.parameterize.to_sym
		if params.key?(resource_key) and params[resource_key].key?(:archetype)
			
			id = params[resource_key][:archetype]
			
			if id.present?
				resource = self.class.duplicatable_model.unscoped.find(id)
				params[resource_key][:archetype_id] = resource.id
				params[resource_key][:archetype_type] = resource.class.name
				
			else # unmark as duplicate
				params[resource_key][:archetype_id] = nil
				params[resource_key][:archetype_type] = nil
			end
			
			params[resource_key].delete :archetype
		end
	end
end