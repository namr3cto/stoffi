module ArtistsHelper
	def no_artists
		"<li class='no-results'>#{t('artists.empty')}</li>".html_safe
	end
end