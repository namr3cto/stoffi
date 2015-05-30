Welcome to Stoffi
=================

![Screenshot](https://www.stoffiplayer.com/assets/us/start.png)

Welcome to the world's next music player.

This project should not be taken very seriously. It is mostly a playground for me, allowing me to experiment with different technologies in something that resembles a real world project. However, over the last couple of years Stoffi has grown into something that's no longer very tiny or limited in scope. I've actually managed to create quite a few features.

Go to [stoffiplayer.com](http://stoffiplayer.com) for more information and to download the player.

## Features

* Streaming from YouTube, SoundCloud, Internet radio
* Sharing on Facebook, Twitter and Last.fm
* Uploading listens to Facebook and Last.fm
* Cloud synchronization
* Playlist subscriptions
* Dynamic playlists
* Plugins (visualizers and filters)
* Random playlist generator
* Silent upgrades (no interaction needed)
* Bookmarks
* Remote control

## Where is Stoffi?

This repo is actually just a pseudo repo. Stoffi is actually divided into several repositories.

The [stoffi-web](https://github.com/simplare/stoffi-web) repo contains the website which contains general information about the project, but also the cloud API.

The repo [stoffi-player-core](https://github.com/simplare/stoffi-player-core) is a cross-platform library which contains the core of the music player. Here you find code for managing playlists, playing music, talking to the cloud, and more.

The Windows player resides at [stoffi-player-win](https://github.com/simplare/stoffi-player-win).

Finally there's the plugin API at [stoffi-player-plugin](https://github.com/simplare/stoffi-player-plugin) which is what you would base your plugin code on if you wanted to write a plugin.

There's actually more repos which I haven't created yet. For example the not-yet-finished GUI for Mac OS X, the Chrome extension, as well as the remote app for iPhone. I will publish these repos either when I decide to continue to work on them, or if someone actually requests them. :)

## Contribute

If you want to contribute, just fork the repos where you want to do work, start coding, rebase your commits and publish a pull request.