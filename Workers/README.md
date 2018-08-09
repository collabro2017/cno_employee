Node Worker
===

##Requirements

###Utility
* ruby 2.1.2
* redisio
* postgresql 9.2

###Gems
*bundler
*resque
*pg (postgresql adapter)

##Setup

Starting from the Cno project's root directory:

`cd NodeWorker/`

*Make sure redis is running else run the follwing command `redis-server`*

#### Redis Configuration
In the directory `~/redis/redis-stable/redis.conf` make sure to add the following:

`bind 0.0.0.0`

This is important because jobs must set inside the NodeWorker's redis server

This must be done also in the In Memory datastore since the jobs will update the remote results key with the bitmap generated
during the process

*TODO*
*Add a password for auth
*Use a different port for the redis server

Then:

1. Install bundle `gem install bundler`
2. Run bundler command `bundle install`
3. Run resque's rake task `rake resque:work QUEUE='process_high_card'`
4. Run resque-web -p 8282