@kopool.controller('WeeksCtrl', ($scope, $routeParams, $http) ->
  console.log("WeeksCtrl")
  console.log($routeParams)

  $scope.weeks = []

  $http.get("./seasons/#{$routeParams.season_id}/weeks.json").success((data) ->
    console.log("data: " + data)
    $scope.weeks = data

    console.log("weeks:" + $scope.nfl_teams)
  )
)