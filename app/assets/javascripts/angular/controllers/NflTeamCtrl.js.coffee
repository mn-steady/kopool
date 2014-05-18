@kopool.controller 'NflTeamsCtrl', ['$scope', '$location', '$http', '$routeParams', 'NflTeam', ($scope, $location, $http, $routeParams, NflTeam) ->
  # $scope.nfl_teams = []
  # $http.get('./nfl_teams.json').success((data) ->
  #   $scope.nfl_teams = data
  # )

  console.log("NflTeamsCtrl")

  console.log("$location:" + $location)

  # This is the OLD way calling the api directly (need to inject $resource)
  # $scope.nfl_teams = []
  # $http.get('./nfl_teams.json').success((data) ->
  #   console.log("data:" + data)
  #   $scope.nfl_teams = data
  #   console.log("nfl_teams:" + $scope.nfl_teams)
  # )

  console.log("Passed id:" + {id: $routeParams.id})

  team_id = $routeParams.id

  # See page 180 in the book for this stuff... You could also setup two controllers (e.g. EditNflTeamsController...)
  if team_id? and team_id == "new"
    console.log("...Creating a new team")
    $scope.nfl_team = new NflTeama
  else if team_id?
    console.log("...Looking up a single team")
    $scope.nfl_team = NflTeam.get({id: team_id})
  else
    console.log("...All Teams")
    #$scope.nfl_team = NflTeam.get({id: $routeParams.id})
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


]