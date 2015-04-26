play = ->
	btn = $('.remote .play-pause')
	icn = btn.find('i.fa')
	icn.removeClass 'fa-play'
	icn.addClass 'fa-pause'
	btn.attr 'data-button-state', 'playing'
	
pause = ->
	btn = $('.remote .play-pause')
	icn = btn.find('i.fa')
	icn.removeClass 'fa-pause'
	icn.addClass 'fa-play'
	btn.attr 'data-button-state', 'paused'
	
playPause = ->
	btn = $('.remote .play-pause')
	if btn.attr('data-button-state') == 'playing'
		pause()
	else
		play()

@updateConfiguration = (id, params) ->
	for field of params
		switch field
			
			when 'shuffle'
				btn = $('.remote .shuffle')
				btn.attr 'data-button-state', params['shuffle']
				break
				
			when 'repeat'
				btn = $('.remote .repeat')
				lbl = $('.remote .repeat-label')
				if params['repeat'] == 'one' then lbl.show() else lbl.hide()
				btn.attr 'data-button-state', params['repeat']
				break
				
			when 'volume'
				slider = $('.remote .volume-slider')
				slider.value(params['volume'])
				break
				
			when 'media_state'
				btn = $('.remote .play-pause')
				icn = btn.find('i.fa')
				if params[field] == 'Playing'
					icn.removeClass 'fa-pause'
					icn.addClass 'fa-play'
					btn.attr 'data-button-state', 'paused'
				else
					icn.addClass 'fa-pause'
					icn.removeClass 'fa-play'
					btn.attr 'data-button-state', 'playing'
				break
				
			when 'now_playing'
				title = params[field] || trans[locale]["media.nothing_playing"]
				break
		
@executeRemote = (command, params) ->
	switch command
		when 'play' then play()
		when 'pause' then pause()
		when 'play-pause' then playPause()