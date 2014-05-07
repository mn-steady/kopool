@kopoo.controller 'WeeksCtrl', ['$scope', '$location', '$http', ($scope, $location, $http)
  console.log("WeeksCtrl")

  $scope.weeks = []

  $http.get('./weeks.json').success((data) ->
    console.log("data: " + data)
    $scope.weeks = data

    console.log("weeks:" + $scope.nfl_teams)
  )

]