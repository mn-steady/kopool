angular.module('Register', ['ngResource', 'RailsApiResource'])

    .controller 'RegisterCtrl', ['$scope', '$location', '$http', '$routeParams', ($scope, $location, $http, $routeParams) ->
      console.log("(RegisterCtrl)")
      $scope.controller = 'RegisterCtrl'

      # user_registration POST   /users(.:format)                             devise/registrations#create
      # new_user_registration GET    /users/sign_up(.:format)                     devise/registrations#new

      console.log("$location:" + $location)
      action = $routeParams.action
      team_id = $routeParams.id

      console.log("Passed id:" + team_id)
      console.log("Passed action:" + action)

      $scope.pool_entries = [{team_name: "???", paid: false}]
      $scope.registering_user = {email: "", password: "", password_conf: "", num_pool_entries: 1, teams: $scope.pool_entries}


    ]