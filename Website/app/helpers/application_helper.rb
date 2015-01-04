# -*- encoding : utf-8 -*-
require 'htmlentities'

module ApplicationHelper
	
	def link_to_association(resources)
		resources.map { |r| link_to h(r), r }.to_sentence.html_safe
	end
	
	def to_words(number)
		l = case I18n.locale
		when :us, :uk then :en
		else I18n.locale end
		I18n.with_locale(l) { number.to_words }
	end
	
	def h(str)
		if str.is_a? String
			str = html_escape(d(str))
		end
		return str
	end

	def title
		t = @title.to_s.strip.empty? ? t("title") : "#{@title} - Stoffi"
		t = "[ALPHA] #{t} [ALPHA]" unless Rails.env.production?
		t
	end
	
	def header(text)
		"<div class='line-behind-text'><h2>#{h text}</h2></div>".html_safe
	end
	
	def pretty_error
		errors = []
		if resource and resource.errors and resource.errors.count > 0
			errors << resource.errors.full_messages[0]
		end
		errors << flash[:error] if flash[:error].present?
		errors << flash[:alert] if flash[:alert].present?
		errors.join '<br/>'
	end
	
	def any_errors?(resource = nil)
		flash[:error].present? or
		flash[:alert].present? or
		(resource and resource.errors and resource.errors.count > 0)
	end
	
	def pretty_url(url, remove_www = false)
		if url.starts_with? 'http://'
			url = url[7..-1]
		elsif url.starts_with? 'https://'
			url = url[8..-1]
		end
		
		if url.starts_with? 'www.' && remove_www
			url = url[4..-1]
		end
		
		if url.ends_with? '/'
			url = url[0..-2]
		end
		
		return url
	end
	
	def expandable(text, options = {})
		options.reverse_merge!({:length => 100})
		attr = ""
		attr = content_tag(:div, raw(options[:attribution]), :class => "attribution throw-right") if options[:attribution]
		options[:attribution] = nil
		return raw(text) if text.length < options[:length]
		content_tag(:div, options.merge(:class => 'expandable')) do
			content_tag(:span, raw(text), :class => 'expanded', :style => 'display:none') +
			content_tag(:span, raw(truncate_html(text, :length => options[:length])), :class => 'contracted') +
			attr +
			content_tag(:span, :class => 'expander') do
				link_to t("show_more"), '#', onclick: "expand(this);"
			end
		end
	end
	
	def custom_button_tag(text, destination, image = "", options = {})
		options.reverse_merge!(
		{
			:type => :link
		})
		
		c = "button"
		c+= " #{options[:color]}" if options[:color]
		c+= " #{options[:class]}" if options[:class]
		s = ""
		s+= "width:#{options[:width]}px;" if options[:width]
		s+= "height:#{options[:height]}px;" if options[:height]
		
		if image != ""
			unless image.starts_with?("http://") ||
			       image.starts_with?("https://") ||
			       image.starts_with?("/")
				image = "gfx/buttons/#{image}.png"
			end
			image = image_tag(image)
		end
		sub = content_tag(:span, raw(options[:subtitle])) if options[:subtitle]
		h1class = ""
		h1class = "large" if options[:subtitle]
		content = content_tag(:h1, d(text), :class => h1class) + sub
		content = raw(image + content_tag(:div, content, :class => :text))
		
		if options[:type] == :link
			filtered_options = [:type, :color, :class, :width, :height, :subtitle]
			link_to(content, destination, {
				:class => c,
				:style => s,
				:id => options[:id]
			}.merge(options.reject { |k,v| filtered_options.include? k }))
			
		elsif options[:type] == :function
			link_to(content, '#', onclick: destination, :class => c, :style => s, :id => options[:id])
		elsif options[:type] == :form
			destination = "" unless destination
			link_to(content, '#', onclick: "#{destination}$(this).closest('form').submit()", :class => c, :style => s, :id => options[:id])
		end
	end
	
	def item(text, resource, field, options = {})
		options.reverse_merge!(
		{
			:delete => t("delete", :item => text),
			:image_size => 120
		})
		
		if resource.is_a? Hash
			resource = case resource[:kind]
			when "song"
				Song.get_by_path(resource[:path])
			
			when "artist"
				Artist.find(resource[:id])
			
			when "playlist"
				Playlist.find(resource[:id])
			
			when "device"
				Device.find(resource[:id])
			
			end
		end
		
		unless resource
			return raw("<li class='collapsed'></li>")
		end
		
		collection = resource.class.name.pluralize.downcase
		id = "#{resource.class.name.downcase}-#{resource.id}"
		id = "#{options[:id_prefix]}-#{id}" if options[:id_prefix]
		
		# check if user has access to delete resource
		can_del = false #admin?
		if user_signed_in? and not can_del
			can_del = (resource.is_a?(User)     and current_user == resource)
			can_del = (resource.is_a?(Playlist) and current_user == resource.user) unless can_del
			can_del = (resource.is_a?(Device)   and current_user == resource.user) unless can_del
			can_del = (resource.is_a?(Song)     and options[:delete_func] or admin?) unless can_del
			can_del = (resource.is_a?(Artist)   and admin?) unless can_del
			can_del = (resource.is_a?(Album)    and admin?) unless can_del
		end
		
		meta = options[:meta].to_s
		if resource.is_a?(Donation) and meta == ""
			can_del = (user_signed_in? and resource.revokable? and (admin? or resource.user == current_user))
			meta = content_tag(:span, t("donations.status.#{resource.status}").downcase,
				:data =>
				{
					:field => "donation-#{resource.id}-status",
					:status => resource.status.downcase,
				})
			meta = "$#{resource.amount}, #{t("donations.status.label").downcase}: "+meta
			
		elsif resource.is_a?(Device) and meta == ""
			meta = content_tag(:span, t("device.status.#{resource.status}").downcase,
				:data =>
				{
					:field => "device-#{resource.id}-status",
					:status => resource.status.downcase,
				})
			meta = "#{t("device.status.label").downcase}: "+meta
			
			options[:class] = "#{options[:class]} #{resource.status == 'online' ? 'active' : 'inactive'}"
		end
		
		if options[:meta] == :donations
			amount = 0
			if resource.is_a?(User)
				amount = resource.donated_sum
			
			elsif resource.is_a?(Artist)
				amount = resource.donated_sum
			end
			
			meta = number_to_currency(amount, :locale => :en)
		end
		
		meta = content_tag(:p, raw(meta), :class => :meta) unless meta == ""
		
		del_url = polymorphic_path(resource, :format => :json)
		del_url = options[:delete_url] if options[:delete_url]
		url = url_for(resource)
		url = options[:url] if options[:url]
		
		image = ""
		image = image_tag(options[:image], :width => options[:image_size], :height => options[:image_size]) if options[:image]
		text = content_tag(:p, d(text), :data => { :field => field })
		
		del = ""
		if can_del
			if resource.is_a?(Donation)
				del = "#{donation_url(resource, :format => :json)}?donation[status]=revoked"
				del = link_to "x", del, :method => :put, :remote => true,
					:class => :delete,
					:data =>
					{
						:element => "donation-revoke-link",
						:objectid => resource.id
					},
					:id => "revoke-link-#{resource.id}",
					:title => t("donations.revoke_tooltip")
			else
				del = "removeItem('#{del_url}', '#{id}', event, '#{collection}')"
				del = options[:delete_func] if options[:delete_func]
				del = link_to "x", '#',
					onclick: del,
					:class => :delete,
					:title => h(options[:delete])
			end
			del = content_tag(:div, del, :class => 'delete-wrap')
		end
		
		cont = content_tag(:div, raw(text + meta), :class => :text)
		content = raw(del + link_to(raw(image + cont), url, :class => "item"))
		content_tag(:li, raw(content), :data => { :object => id }, :class => options[:class])
	end
	
	def editable_label(resource, property, options = {})
		options.reverse_merge!(
		{
			:tag => :h1,
			:width => 20
		})
	
		cname = resource.class.name.downcase
		prop = property.to_s.downcase
		val = resource[property]
		id = "#{cname}-#{resource.id}-#{prop}"
		url = polymorphic_path(resource, :format => :json)
		field = "#{cname}[#{prop}]"
	
		lclass = ""
		box = ""
		click = ""
		if admin?
			box = text_field_tag("#{id}-box", d(val),
				:class => "editable-#{options[:tag]}",
				:size => options[:width],
				:style => "display:none;",
				:onkeydown => "editable_box_keydown('#{id}', '#{url}', '#{field}', event);",
				:onblur => "editable_box_blur('#{id}', '#{url}', '#{field}', event);")
				
			lclass = "editable"
			click = "editable_label_click('#{id}')"
		end
			
		label = content_tag(options[:tag], d(val),
			:data => { :field => "#{cname}-#{prop}" },
			:class => lclass,
			:id => "#{id}-label",
			:onclick => click)
		
		return raw(box + label)
	end
end
