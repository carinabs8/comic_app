# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
	***3.0.1***

* System dependencies
	***Docker
	Github***

# Configuration

* Database creation
	* Postgres is a requirement of this project
		* ***bundle exec rake db:create***

* Database initialization
	*		***docker-compose run web rake db:create***
	*		***docker-compose run web rake db:schema:load***
	* 	***docker-compose run web rake db:migrate***

* How to run the test suite
	* 	In a way to run tests you need beeing setup postgres database as requirement.
		* 	***bundle exec rake db:create***
		* 	***bundle exec rake db:schema:load***
		* 	***bundle exec rspec***

* Services (job queues, cache servers, search engines, etc.)
	*	This project uses cache, so you need to start redis as a service 

* Deployment instructions
	* 	This project uses docker. So, to deploy you just need run docker-compose up
		* 	**docker-compose up**
* This backend is available under **4001*** port
# Http rests
	1	GET localhost:4001/book_covers
	2	POST localhost:4001/book_covers/search
	3	POST localhost:4001/**:book_covers**/22317/upvote
