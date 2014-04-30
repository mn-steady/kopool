@nflteams.controller 'NflTeamIndexCtrl', ['$scope', '$location', '$http', ($scope, $location, $http) ->
  # $scope.nfl_teams = []
  # $http.get('./nfl_teams.json').success((data) ->
  #   $scope.nfl_teams = data
  # )

  $scope.nfl_teams = NflTeam.all()
  console.log("nfl_teams:" + $scope.nfl_teams)

]