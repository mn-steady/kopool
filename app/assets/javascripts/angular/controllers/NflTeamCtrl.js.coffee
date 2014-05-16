@kopool.controller 'NflTeamsCtrl', ['$scope', '$location', '$http', 'NflTeam', ($scope, $location, $http, NflTeam) ->
  # $scope.nfl_teams = []
  # $http.get('./nfl_teams.json').success((data) ->
  #   $scope.nfl_teams = data
  # )

  console.log("NflTeamsCtrl")

  # This is the OLD way calling the api directly (need to inject $resource)
  # $scope.nfl_teams = []
  # $http.get('./nfl_teams.json').success((data) ->
  #   console.log("data:" + data)
  #   $scope.nfl_teams = data
  #   console.log("nfl_teams:" + $scope.nfl_teams)
  # )

  $scope.nfl_teams = NflTeam.query()

  $scope.selectTeam = (team) ->
    console.log("---> Selecting " + team.name)
    $scope.selectedTeam = team

  $scope.isSelected = (team) ->
    $scope.selectedTeam == team


]