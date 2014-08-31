module SearchHelper
	def category_selected?(category)
		@categories == [category] or (category == 'all' and @categories == Search.categories)
	end
	
	def search_path_with_categories
		c = nil
		c = @categories.join('|') unless @categories.include? 'all' or @categories == Search.categories
		search_path(categories: c)
	end
	
	def no_search_results
		"<li class='no-results'>#{t('search.empty')}</li>".html_safe
	end
end