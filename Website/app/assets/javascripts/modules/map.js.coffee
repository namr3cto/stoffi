
initMap = (div) ->
	lng = div.data('longitude')
	lat = div.data('latitude')
	mrk = div.data 'marker'
	pos = new google.maps.LatLng(lat, lng)
	i = null
	
	map = new google.maps.Map div[0], {
		zoom: 3,
		center: pos,
		mapTypeId: google.maps.MapTypeId.TERRAIN
	}
	
	infowindow = new google.maps.InfoWindow()
	
	marker = new google.maps.Marker {
		position: pos,
		map: map
	}
	
	google.maps.event.addListener marker, 'click', ((marker, i) ->
		() ->
			infowindow.setContent mrk
			infowindow.open map, marker
	)(marker, i)

$ ->
	initMap $(map) for map in $('[data-map]')