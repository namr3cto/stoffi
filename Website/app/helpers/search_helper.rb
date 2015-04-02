module SearchHelper
	def no_search_results
		"<div class='no-results'>#{t('search.empty')}</div>".html_safe
	end
end