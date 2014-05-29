README for KoPool
-----------------

Rails 4, Ruby 2(?), Postgres

Overview of Original Site's Menus

Looks like a given user can have more than one "team" and we need to keep track of payments in that scenario


Installation


Useful Blog Posts
-----------------
##Blog Posts that have proven useful
- [Getting Started with Angular and Rails 4](http://www.honeybadger.io/blog/2013/12/11/beginners-guide-to-angular-js-rails)
- [How to Integrate Angular with Rails 4](https://shellycloud.com/blog/2013/10/how-to-integrate-angularjs-with-rails-4) Has good CoffeeScript examples as well as CSRF and turbolinks issues resolved.
- [Angular JS, Rails, and HAML](http://www.amberbit.com/blog/2014/1/20/angularjs-templates-in-ruby-on-rails-assets-pipeline/)
- [4 lessons learned doing angular on rails](http://gaslight.co/blog/4-lessons-learned-doing-angular-on-rails)
- [Angular and HTML5 localStorage](http://www.amitavroy.com/justread/content/articles/html5-local-storage-angular-js)
- [Angular and HTML5 datastore](http://stackoverflow.com/questions/17888884/service-retrieves-data-from-datastore-but-does-not-update-ui)



==Running Tests
bundle exec rspec

RAILS_ENV=test bundle exec rake spec:javascript



For inline docs:
bundle exec rspec --format d

For HTML output of docs:
bundle exec rspec --format h

Administrative
* KOPools
  - Indexes Pools
  - Create New Pool - One for each year basically
* NFL Matchups
  - Select a week
  - Indexes NFL Matchups for that week
  - Matchup: Date, Time, Team A, Team B.  One of A or B is Home Team ("AT:<home team>")
  - Create Matchup asks you for Week ID, Date/Time, Home Team, Away Team
* NFL Weeks
  - Week: Start Date, End Date, Pick Deadline, Default Team
  - Create Week presumably lets you create one
* NFL Teams
  - Team: Conf (NFC/AFC), Division(North,South,East,West), Team Name, Abbreviation, Home Location(Stadium Name), Logo
* Participants (Users)
  - Participant: pool_id, first_name, last_name, address1, address2, city, state, zip, favorite_team_id, phone, cell, paid_at, comments
* Participants / Payments
  - Participant has many pool_entries
  - pool_entry has many payments
  - payment has date, pool_entry_id, amount
* Missing Picks
  - Participant.name, phone, nickname
* Email Missing Picks
  - Without Confirmation (?!) Automatically sends an email to everyone

Contact Us
* Simple form with name, email, phone, subject, and message.  Presumably emails the administrator

My Picks
* Show you your weekly picks.  Your username (pool name?), "Round 1", Your pick

Pool Entries
* Since a given user can have many pools, shows you your pools and whether any payments are due

Round X
* Shows you the current stats for the given round
"Still Standing":   # and percentage
"Knocked Out": # and percentage
"Missing Picks" # and percentage.

Then lists the still-standing pools (sequence and Pool.name)
Then lists the knocked-out pools (sequence, Pool.name, week-knocked-out, team-who-lost)

Rules
Just a summary page of the rules.

Hyperlink at top of screen to change your password

Ability to Logoff

Home page has the current round, the default pick (team name and icon), and some pictures that Dave can update.
Would be nice to use "ActiveAdmin" if that has been maintained so that dave can edit some of these pages himself.
Probably requires a page model.



MODELS

Pool name:string
PoolUsers
User
PoolUserPayments
Round round_number:integer


ToDo week of May 5th

Jack:
* Try to get Devise working through AngularJS according to http://jes.al/2013/08/authentication-with-rails-devise-and-angularjs/

Dad:
* CRUD for NFL teams including images.
