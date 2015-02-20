module DuplicatableController
	extend ActiveSupport::Concern
	
	included do
		before_filter :redirect_duplicates, only: [:show]
	end
	
	private
	
	def redirect_duplicates
		song = Song.unscoped.find(params[:id])
		redirect_to song.archetype and return if song.duplicate?
	end
end