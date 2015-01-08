# -*- encoding : utf-8 -*-
module UsersHelper
	def text_ads?
		current_user == nil || current_user.show_ads != "none"
	end
	
	def image_ads?
		current_user == nil || (current_user && current_user.show_ads == "all")
	end
	
	def name_options_for_select
		options = []
		
		current_user.links.each do |l|
			l.names.each do |label,name|
				options << ["#{name} (#{l})", "#{l.provider}::#{label}"]
			end
		end
		
		options << [t('settings.custom'), '']
		
		options_for_select options, current_user.name_source
	end
	
	def image_options_for_select
		options = [[t('settings.default'), '', { data: { imagesrc: image_path('media/user.png') }}]]
		
		current_user.links.each do |l|
			if l.picture? and l.picture
				options << [l.display, l.provider, { data: { imagesrc: l.picture }}]
			end
		end
		
		[:mm, :identicon, :monsterid, :wavatar, :retro].each do |i|
			name = i == :mm ? "Gravatar" : i.to_s
			disp = name.titleize
			disp = 'MonsterID' if name == 'monsterid'
			options << [disp, name, { data: { imagesrc: current_user.gravatar(i) }}]
		end
		
		options_for_select options, current_user.image
	end
end
