
#
# Preloads a bunch of images.
#
# param @images
#   An array of image URLs to preload.
#
@preloadImages = (images) ->
	if document.images
		for image in images
			imgObj = new Image()
			imgObj.src = image
			