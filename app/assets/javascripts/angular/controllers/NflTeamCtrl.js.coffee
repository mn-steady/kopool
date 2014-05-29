@kopool.controller 'NflTeamsCtrl', ['$scope', '$location', '$http', '$routeParams', 'NflTeam', ($scope, $location, $http, $routeParams, NflTeam) ->

  console.log("NflTeamsCtrl")
  console.log("$location:" + $location)

  action = $routeParams.action
  team_id = $routeParams.id

  console.log("Passed id:" + team_id)
  console.log("Passed action:" + action)


  # See page 180 in the book for this stuff... You could also setup two controllers (e.g. EditNflTeamsController...)
  if team_id? and action == "delete"
    console.log("Action is delete")
    $scope.nfl_team = NflTeam.delete({id: team_id})
  if team_id? and team_id == "new"
    console.log("...Creating a new team")
    $scope.nfl_team = new NflTeam
  else if team_id?
    console.log("...Looking up a single team")
    $scope.nfl_team = NflTeam.get({id: team_id})
  else
    console.log("...All Teams")
    $scope.nfl_teams = NflTeam.query()

  $scope.selectTeam = (team) ->
    console.log("---> Selecting " + team.name)
    $scope.selectedTeam = team

  $scope.isSelected = (team) ->
    $scope.selectedTeam == team

  $scope.save = (team) ->
    console.log("NflTeamsCtrl.save...")
    if team.id?
      console.log("Saving Team id " + team.id)
      NflTeam.save(team)
    else
      console.log("First-time save need POST new id")
      NflTeam.new(team)
    $location.path ('/nfl_teams')

  $scope.delete = (team) ->
    console.log("NflTeamsCtrl.delete...")
    if team.id?
      console.log("Deleting Team id " + team.id)
      NflTeam.remove(team)
    else
      console.log("Cannot Delete)")

]