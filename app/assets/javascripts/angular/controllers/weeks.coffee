angular.module('Weeks', ['ngResource', 'RailsApiResource'])

  .factory 'Week', (RailsApiResource) ->
      RailsApiResource('seasons/1/weeks', 'weeks')

  .controller 'WeeksCtrl', ['$scope', '$location', '$http', '$routeParams', 'Week', ($scope, $location, $http, $routeParams, Week) ->
    $scope.controller = 'WeeksCtrl'

    console.log("WeeksCtrl")
    console.log($routeParams)

    console.log("$location:" + $location)

    action = $routeParams.action
    week_id = $routeParams.id

    console.log("Passed id:" + week_id)
    console.log("Passed action:" + action)

    if week_id? and week_id == "new"
      console.log("...Creating a new team")
      $scope.week = new Week({})
    else if week_id?
      console.log("...Looking up a single team")
      $scope.week = Week.get(week_id).then((week) ->
        $scope.week = week
      )
    else
      console.log("...All Weeks")
      Week.query().then((weeks) ->
        $scope.weeks = weeks
        console.log("*** Have weeks***")
      )
  ]