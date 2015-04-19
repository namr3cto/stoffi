
$(document).on 'contentReady', ->	
	for e in $('[data-tooltip]')
		$(e).qtip {
			content: $(e).data('tooltip').replace /\\n/g, '<br/>'
			style: 'qtip-light qtip-shadow'
			position: {
				my: 'top left'
				at: 'bottom left'
			}
		}