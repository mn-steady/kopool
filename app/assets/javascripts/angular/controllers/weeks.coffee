angular.module('Weeks', ['ngResource', 'RailsApiResource'])

  .factory 'Week', (RailsApiResource) ->
      RailsApiResource('seasons/:parent_id/weeks', 'weeks')

  .controller 'WeeksCtrl', ['$scope', '$location', '$http', '$routeParams', 'Week', ($scope, $location, $http, $routeParams, Week) ->
    $scope.controller = 'WeeksCtrl'

    console.log("WeeksCtrl")
    console.log($routeParams)

    console.log("$location:" + $location)

    action = $routeParams.action
    $scope.season_id = season_id = $routeParams.season_id
    week_id = $routeParams.id

    console.log("Passed action:" + action)
    console.log("Passed season_id:" + season_id)
    console.log("Passed id:" + week_id)

    if week_id? and week_id == "new"
      console.log("...Creating a new week")
      $scope.week = new Week({})
    else if week_id?
      console.log("...Looking up a single week")
      $scope.week = Week.get(week_id, season_id).then((week) ->
        $scope.week = week
      )
    else
      console.log("...All Weeks for season "+season_id)
      Week.nested_query(season_id).then((weeks) ->
        $scope.weeks = weeks
        console.log("*** Have weeks***")
      )
  ]