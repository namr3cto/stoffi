# -*- encoding : utf-8 -*-
module SongsHelper
	def pretty_link(song)
		if song.artist
			return t "media.song.link_html",
				:title => link_to(song.title, song),
				:artist => link_to(song.artist.name, song.artist)
		else
			return link_to(song.title, song)
		end
	end
	
	def short_link(song)
		l = link_to(song.title, song)
		if song.artist
			l = link_to(song.artist.name, song.artist) + " - " + l
		end
		return l
	end
end
