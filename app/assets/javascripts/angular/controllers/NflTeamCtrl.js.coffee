@nflteams.controller 'NflTeamIndexCtrl', ['$scope', '$location', '$http', ($scope, $location, $http) ->
  $scope.nfl_teams = []
  $http.get('./nfl_teams.json').success((data) ->
    $scope.nfl_teams = data
  )
]