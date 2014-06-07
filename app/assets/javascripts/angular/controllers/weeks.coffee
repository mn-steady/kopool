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
      $scope.week.season_id = $scope.season_id
    else if week_id?
      console.log("...Looking up a single week")
      $scope.week = Week.get(week_id, season_id).then((week) ->
        # week.end_date = Date.parse(week.end_date)
        # week.start_date = Date(week.start_date)
        # week.deadline = week.deadline
        $scope.week = week
        console.log("are the dates date objects?")
      )
    else
      console.log("...All Weeks for season "+season_id)
      Week.nested_query(season_id).then((weeks) ->
        $scope.weeks = weeks
        console.log("*** Have weeks***")
      )

    $scope.save = (week) ->
      console.log("WeeksCtrl.save...")
      if week.id?
        console.log("Saving week id " + week.id)
        Week.save(week, $scope.season_id).then((week) ->
          $scope.week = week
        )
      else
        console.log("First-time save need POST new id")
        Week.create(week, $scope.season_id).then((week) ->
          $scope.week = week
        )
      $location.path ('/seasons/' + $scope.season_id + '/weeks')

    $scope.deleteWeek = (week) ->
      console.log("WeeksCtrl.delete...")
      if week.id?
        console.log("Deleting week id " + week.id)
        Week.remove(week, $scope.season_id).then((week) ->
          # Forcibly reloading the collection refreshes the screen nicely!
          Week.nested_query(season_id).then((weeks) ->
            $scope.weeks = weeks
            $location.path ('/seasons/' + $scope.season_id + '/weeks')
          )
        )
      else
        console.log("Cannot Delete)")
  ]