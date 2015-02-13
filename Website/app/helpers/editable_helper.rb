module EditableHelper
	
	#
	# Create a field which can be edited in-place using a single click.
	#
	# When Enter is pressed the field update is submitted via AJAX.
	# Companions: CoffeeScript module, SCSS module
	#
	def editable_field(tag, resource, field, value, options = {}, &block)
		
		# prepare markup content
		icon = content_tag 'span', '', class: 'icon edit-icon'
		f = "#{resource.class.name.downcase}[#{field}]"
			
		if block_given?
			text = content_tag 'div', capture(&block)+icon, class: :text
			input = text_field_tag f, value, class: :input, data: { autosize_input: '{ "space": 0 }' }
			
			content = text+input
		else
			content = text_field_tag f, value, disabled: true, data: { autosize_input: '{ "space": 0 }' }
			content = content+icon 
		end
		
		# prepare class attribute
		c = ['editable']
		c << options[:class] if options[:class]
		c << 'disabled' if options[:disabled]
		
		# prepare data attribute
		data = {
			editable_url: url_for(resource),
			editable_method: :patch,
		}
		data.merge(options[:data]) if options[:data]
		
		# put it all together
		content_tag tag, content, class: c.join(' '), data: data
	end
	
end