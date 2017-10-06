# README

App tested under Ruby 2.4.2

* `bundle install`

* `rake db:create`

* `rake db:migrate`

To populate database with exchange rates it makes sense to do initial import of exchange rates (located in public/historical_data.json) as it takes some time to 
download all them from 

* `rake fixer:save`

however there is also rake task to reimport everything from fixer API once again `rake fixer:resync`, due to rate limiting from Fixer side,
there will be lot of retries however these tasks will eventually succeed.

* `rails s`