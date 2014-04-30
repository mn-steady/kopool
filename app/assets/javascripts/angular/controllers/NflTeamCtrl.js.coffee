@kopool.controller 'NflTeamsCtrl', ['$scope', '$location', '$http', ($scope, $location, $http) ->
  # $scope.nfl_teams = []
  # $http.get('./nfl_teams.json').success((data) ->
  #   $scope.nfl_teams = data
  # )

  console.log("NflTeamsCtrl")

  $scope.nfl_teams = []

  $http.get('./nfl_teams.json').success((data) ->
    console.log("data:" + data)
    $scope.nfl_teams = data

    console.log("nfl_teams:" + $scope.nfl_teams)

  )

  $scope.simple_variable = "foo"

  #$scope.nfl_teams = NflTeam.all()

  #console.log("nfl_teams:" + $scope.nfl_teams)

]