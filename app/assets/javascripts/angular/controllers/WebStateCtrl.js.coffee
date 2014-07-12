angular.module('WebStates', ['ngResource', 'RailsApiResource'])

  .factory 'WebState', (RailsApiResource) ->
      RailsApiResource('admin/web_states', 'webstate')

  .factory 'Week', (RailsApiResource) ->
      RailsApiResource('weeks', 'weeks')

  .controller 'WebStatesCtrl', ['$scope', '$location', '$http', '$routeParams', 'WebState', 'Week', ($scope, $location, $http, $routeParams, WebState, Week) ->
    $scope.controller = 'WebStatesCtrl'

    console.log("WebStatesCtrl")
    console.log($routeParams)

    console.log("$location:" + $location)

    action = $routeParams.action

    # There is always only 1 webstate record
    console.log("Passed action:" + action)

    console.log("...Looking up the WebState")
    $scope.web_state = WebState.get(1).then((web_state) ->
      $scope.web_state = web_state
      $scope.season = "TBD"

      $scope.reload_week()

    )

    $scope.reload_week = () ->
      $scope.week = Week.get($scope.web_state.week_id).then((week) ->
        $scope.week = week
        console.log("Reloaded week")
        )


    $scope.close_or_reopen_picks = () ->
      console.log("WebStatesCtrl.close_or_reopen_picks...")
      if $scope.week.open_for_picks == true
        console.log("Closing week "+$scope.week_id)
        Week.post(":parent_id/close_week", {}, $scope.week.id)
      else
        console.log("Attempting to re-open week "+$scope.week_id)
        Week.post(":parent_id/reopen_week", {}, $scope.week.id)
      $scope.reload_week()

    $scope.advance_week = () ->
      console.log("WebStatesCtrl.advance_week...")
      console.log("Advancing week "+$scope.week_id)
      Week.post(":parent_id/advance_week", {}, $scope.week.id)
      $scope.reload_week()

    $scope.save = (web_state) ->
      console.log("WebStatesCtrl.save...")
      if web_state.id?
        console.log("Saving web_state id " + web_state.id)
        web_state.save(web_state, $scope.season_id).then((web_state) ->
          $scope.web_state = web_state
        )
      else
        console.log("First-time save need POST new id")
        web_state.create(web_state, $scope.season_id).then((web_state) ->
          $scope.web_state = web_state
        )
      $location.path ('/seasons/' + $scope.season_id + '/web_states')

    $scope.close_or_open_button_text = () ->
      if $scope.week.open_for_picks == true
        "Close for Picks"
      else
        "Re-Open for Picks"

    $scope.current_week_status = () ->
      if $scope.week.open_for_picks == true
        "OPEN FOR PICKS"
      else
        "CLOSED FOR PICKS"

  ]