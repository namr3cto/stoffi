
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
				# 
				# var lat = 59.873154;
				# var lng = 17.641365;
				# 
				# var map = new google.maps.Map(document.getElementById('map'), {
				# 	zoom: 3,
				# 	center: new google.maps.LatLng(lat, lng),
				# 	mapTypeId: google.maps.MapTypeId.TERRAIN
				# });
				# 
				# var infowindow = new google.maps.InfoWindow();
				# var marker, i;
				# 
				# marker = new google.maps.Marker({
				# 	position: new google.maps.LatLng(lat, lng),
				# 	map: map
				# });
				# 
				# google.maps.event.addListener(marker, 'click', (function(marker, i) {
				# 	return function()
				# 	{
				# 		infowindow.setContent("Your device was accessed from this point");
				# 		infowindow.open(map, marker);
				# 	}
				# })(marker, i));

jQuery ->
	initMap $(map) for map in $('[data-map]')