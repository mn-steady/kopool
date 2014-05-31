angular.module('NflTeams', ['ngResource', 'RailsApiResource'])

    .factory 'NflTeam', (RailsApiResource) ->
        RailsApiResource('nfl_teams', 'nfl_teams')

    .controller 'NflTeamsCtrl', ['$scope', '$location', '$http', '$routeParams', 'NflTeam', ($scope, $location, $http, $routeParams, NflTeam) ->

      $scope.controller = 'NflTeamsCtrl'
      console.log("NflTeamsCtrl")
      console.log("$location:" + $location)

      action = $routeParams.action
      team_id = $routeParams.id

      console.log("Passed id:" + team_id)
      console.log("Passed action:" + action)


      if team_id? and team_id == "new"
        console.log("...Creating a new team")
        $scope.nfl_team = new NflTeam({})
      else if team_id?
        console.log("...Looking up a single team")
        $scope.nfl_team = NflTeam.get(team_id).then((nfl_team) ->
            $scope.nfl_team = nfl_team
        )
      else
        console.log("...All Teams")
        NflTeam.query().then((nfl_teams) ->
            $scope.nfl_teams = nfl_teams
        )


      $scope.selectTeam = (team) ->
        console.log("---> Selecting " + team.name)
        $scope.selectedTeam = team

      $scope.isSelected = (team) ->
        $scope.selectedTeam == team

      $scope.save = (team) ->
        console.log("NflTeamsCtrl.save...")
        if team.id?
          console.log("Saving Team id " + team.id)
          NflTeam.save(team).then((nfl_team) ->
            $scope.nfl_team = nfl_team
          )
        else
          console.log("First-time save need POST new id")
          NflTeam.create(team).then((nfl_team) ->
            $scope.nfl_team = nfl_team
          )
        $location.path ('/nfl_teams')

      $scope.deleteTeam = (team) ->
        console.log("NflTeamsCtrl.delete...")
        if team.id?
          console.log("Deleting Team id " + team.id)
          NflTeam.remove(team).then((nfl_team) ->
            # Forcibly reloading the collection refreshes the screen nicely!
            NflTeam.query().then((nfl_teams) ->
              $scope.nfl_teams = nfl_teams
              $location.path ('/nfl_teams')
            )
          )
        else
          console.log("Cannot Delete)")

    ]