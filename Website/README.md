= The Stoffi Website

As you may know, Stoffi is divided into two parts: the player (hopefully it will soon be 'players') and the website.

The website, also know as the Cloud, is the central point which ties all your devices together and acts as a central repository for all configurations, playlists and statistics. The website is also the communicator between the player and the rest of the Internet such as Facebook and Google.

== Getting started

If you are reading this you are probably interested in getting the Stoffi website setup on your own development machine. Since the website is rather complex, there are a few steps you need to complete in order to get it up and running.

=== Prerequisites

First I suggest you setup Ruby and Ruby on Rails along with a web server on your machine. I suggest you check out Pow as a local web server. It is fast and easy to deploy. I also suggest you use RVM to manage various ruby versions. The current master branch of Stoffi is developed using Ruby 2.1.

You also need to install Juggernaut in order to get server-to-client communication up and running. I will move to WebSockets later when I have managed to switch to a more modern browser for the embedded version inside the player. But for now, we still use Juggernaut. Here's how you install it.

Install Node.js:

	brew install node
	
Install Redis:

	brew install redis
	
Install juggernaut:

	npm install -g juggernaut
	
For some reason I didn't get the latest version of Juggernaut to work. It started to run but never served any requests. I have packaged the folder from the web server which *does* work, and put it into the `vendor` folder. Unpack this into the juggernaut installation folder, which is most likely `/usr/local/lib/node_modules/juggernaut`.

=== Database setup

Start by creating the database configuration file `config/database.yml`. TODO: add a default configuration file but prevent it from being changed accidentally.

Then create the database:

	rake db:create
	
You may need to migrate to the latest version of the schema. TODO: this shouldn't be needed!

	rake db:migrate
	
Now initialize the database:

	rake db:seed
	
=== Start services

Start redis:

	redis-server

Start juggernaut:

	juggernaut --port 8080
	
Note that if you decide to serve the website over https you should change the port to 8443.

Start the sunspot search engine:

	rake solr:sunspot:start
	
TDOO: perhaps we could combine all these into a single rake task?

=== Secrets

You also need to create the file `config/secrets.yml`. TODO: create default sample file with instructions.

== Getting to work

When you have everything setup you can start to do some work. Follow the usual workflow when doing work.

=== Tests

Remember to continuously run the automatic tests while working to ensure that you don't break stuff by accident.

	rake test
	
=== Documentation

If you need to build the documentation run the following:

	rake doc