module RankableHelper
	def top_list(resource, options = {})
		options = { limit: 5, links: true }.merge(options)
		x = resource.top.limit(options[:limit])
		x = x.map do |a|
			options[:links] ? link_to(h(a.display), a) : a.display
		end.to_sentence
		x.html_safe
	end
end