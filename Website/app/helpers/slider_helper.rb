module SliderHelper
	
	def slider(options = {})
		options = {
			value: 50
		}.merge(options)
		
		thumb = icon('circle', class: :thumb)
		content_tag :span, thumb, class: :slider, data: {
			'slider-value' => options[:value]
		}
	end
	
end