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

      $scope.pool_entries = [{team_temp_id: 0, team_name: "???", paid: false}]
      $scope.registering_user = {email: "", password: "", password_conf: "", num_pool_entries: 1, teams: $scope.pool_entries, is_registered: false}
      $scope.editing_team = 1


      $scope.make_registered_user = () ->
        # TODO: Call Devise and verify also
        $scope.registering_user.is_registered = true

      $scope.total_charges = () ->
        "$" + $scope.registering_user.num_pool_entries * 50.00 + ".00"

      $scope.$watch 'editing_team', (newVal, oldVal) ->
        console.log("(Register.watch) old="+oldVal)
        console.log("(Register.watch) new="+newVal)
        console.log("(Register.watch) was editing team:" + $scope.editing_team)
        num_existing_teams = $scope.registering_user.teams.length
        console.log("(Register.watch) existing team count="+ num_existing_teams)
        if newVal > num_existing_teams
          if num_existing_teams == $scope.registering_user.num_pool_entries
            console.log("CANNOT ADD ANY MORE TEAMS")
            newVal = oldVal
            $scope.editing_team = oldVal
          else
            console.log("Pushing a new team")
            $scope.pool_entries.push({team_temp_id: 1, team_name: "new", paid: false})
            $scope.registering_user.num_pool_entries++

        $scope.pool_entry_text = () ->
          if $scope.registering_user.num_pool_entries > 1
            "your " + $scope.registering_user.num_pool_entries + " pool entries"
          else
            "your pool entry"

        $scope.team_badge_text = (team_index) ->
          "Team " + (team_index+1) + " of " + $scope.registering_user.num_pool_entries

    ]