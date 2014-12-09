README for KoPool
-----------------

Rails 4, Ruby 2, Postgres


Installation
------------


Useful Blog Posts
-----------------
##Blog Posts that have proven useful
- [Getting Started with Angular and Rails 4](http://www.honeybadger.io/blog/2013/12/11/beginners-guide-to-angular-js-rails)
- [How to Integrate Angular with Rails 4](https://shellycloud.com/blog/2013/10/how-to-integrate-angularjs-with-rails-4) Has good CoffeeScript examples as well as CSRF and turbolinks issues resolved.
- [Angular JS, Rails, and HAML](http://www.amberbit.com/blog/2014/1/20/angularjs-templates-in-ruby-on-rails-assets-pipeline/)
- [4 lessons learned doing angular on rails](http://gaslight.co/blog/4-lessons-learned-doing-angular-on-rails)
- [Angular and HTML5 localStorage](http://www.amitavroy.com/justread/content/articles/html5-local-storage-angular-js)
- [Angular and HTML5 datastore](http://stackoverflow.com/questions/17888884/service-retrieves-data-from-datastore-but-does-not-update-ui)
- [Sharing code between controllers using services](http://fdietz.github.io/recipes-with-angular-js/controllers/sharing-code-between-controllers-using-services.html)


Issue of login page rendering multiple times
--------------------------------------------
http://stackoverflow.com/questions/18079242/angularjs-controller-execute-twice

In AngularJS, anything wrapped in double curly braces is an expression that gets evaluated at least once during the digest cycle.

AngularJS works by running the digest cycle continuously until nothing has changed. That's how it ensures the view is up-to-date. Since you called a function, it's running it once to get a value and then a second time to see that nothing has changed. On the next digest cycle, it will run at least once again.

http://stackoverflow.com/questions/16883446/watch-not-working-on-variable-from-other-controller


==Running Tests
bundle exec rspec

RAILS_ENV=test bundle exec rake spec:javascript



For inline docs:
bundle exec rspec --format d

For HTML output of docs:
bundle exec rspec --format h

For ERD / Structure Diagram:
budnle exec erd
(makes erd.pdf)


==Pushing to Heroku
Normally will be:
git push heroku master

If you want to push a feature branch:
git push heroku heroku_push:master

heroku run rake db:seed
heroku run rake db:migrate
heroku run rails console
