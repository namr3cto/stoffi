module RankableHelper
	def top_list(resource, options = {})
		options = { limit: 5, links: true }.merge(options)
		x = resource.top.limit(options[:limit])
		x = x.map do |a|
			options[:links] ? link_to(h(a), a) : a
		end.to_sentence
		x.to_s.html_safe
	end
end