activeSlider = null

activateSlider = (event, thumb) ->
	event.preventDefault()
	activeSlider = thumb
	
deactivateSlider = ->
	return unless activeSlider
	activeSlider.closest('.slider').trigger 'changed'
	activeSlider = null
	
moveSlider = (event) ->
	return unless activeSlider
	thumb = activeSlider
	slider = thumb.closest('.slider')
	offset = slider.offset()
	pos = 100 * (event.pageX - offset.left) / slider.width()
	setValue slider, pos
	
setValue = (slider, value) =>
	thumb = $(slider).closest '.thumb'
	value = 0 if value < 0
	value = 100 if value > 100
	slider.data 'slider-value', value
	$(slider).find('.thumb').css 'left', "#{value}%"
	
getValue = (slider) ->
	parseFloat($(slider).find('.thumb').css('left'))
	
$(document).on 'contentReady', ->
	$('.slider .thumb').when 'mousedown', (event) ->
		activateSlider event, $(@)
	$(document).when 'mouseup', ->
		deactivateSlider()
	$(document).when 'mousemove', (event) ->
		moveSlider(event)
		
	for slider in $('.slider[data-slider-value]')
		p = $(slider).data 'slider-value'
		$(slider).find('.thumb').css 'left', "#{p}%"
		
	$.fn.value = (v) ->
		return unless $(@).find('.thumb').length > 0
		if v?
			setValue $(@), v
		else
			getValue $(@)