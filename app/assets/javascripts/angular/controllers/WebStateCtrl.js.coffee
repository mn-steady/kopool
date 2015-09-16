angular.module('WebStates', ['ngResource', 'RailsApiResource', 'ui.bootstrap'])

  .factory 'WebState', (RailsApiResource) ->
      RailsApiResource('admin/web_states', 'webstate')

  .factory 'Week', (RailsApiResource) ->
      RailsApiResource('weeks', 'weeks')

  .controller 'WebStatesCtrl', ['$scope', '$location', '$http', '$routeParams', 'WebState', 'Week', '$modal', 'Matchup', ($scope, $location, $http, $routeParams, WebState, Week, $modal, Matchup) ->
    $scope.controller = 'WebStatesCtrl'
    $scope.matchupToLock = {}

    console.log("WebStatesCtrl")
    console.log($routeParams)

    console.log("$location:" + $location)

    action = $routeParams.action

    # There is always only 1 webstate record
    console.log("Passed action:" + action)

    $scope.week = {}

    $scope.getWebState = () ->
      console.log("...Looking up the WebState")
      $scope.web_state = WebState.get(1).then((web_state) ->
        $scope.web_state = web_state
        $scope.season = "TBD"
        $scope.reload_week()
        $scope.loadMatchups()
      )

    $scope.getWebState()

    $scope.loadMatchups = () ->
      Matchup.nested_query($scope.web_state.current_week.id).then((matchups) ->
        $scope.matchups = matchups
        console.log "Have matchups: ", $scope.matchups
      )

    $scope.reload_week = () ->
      $scope.week = Week.get($scope.web_state.week_id).then((week) ->
        $scope.week = week
        console.log("Reloaded week")
        )


    $scope.close_or_reopen_picks = () ->
      console.log("WebStatesCtrl.close_or_reopen_picks...")
      if $scope.week.open_for_picks == true
        console.log("Closing week "+$scope.week.id)
        Week.post(":parent_id/close_week", {}, $scope.week.id)
      else
        console.log("Attempting to re-open week "+$scope.week.id)
        Week.post(":parent_id/reopen_week", {}, $scope.week.id)
      $scope.reload_week()

    $scope.advance_week = () ->
      console.log("WebStatesCtrl.advance_week...")
      console.log("Advancing week "+$scope.week.id)
      Week.post(":parent_id/advance_week", {}, $scope.week.id).then(() ->
        $scope.getWebState()
      )


    $scope.save = (web_state) ->
      console.log("WebStatesCtrl.save...")
      console.log("Saving web_state id " + web_state.id)
      WebState.save(web_state).then((web_state) ->
          $scope.web_state = web_state
      )


    $scope.close_or_open_button_text = () ->
      if $scope.week.open_for_picks == true
        "Close for Picks"
      else
        "Re-Open for Picks"

    $scope.current_week_status = () ->
      if $scope.week.open_for_picks == true
        "OPEN for picks"
      else
        "CLOSED for picks"

    $scope.updateMatchupLock = (locked = true) ->
      console.log "Locked = ", locked
      console.log "In updateMatchupLock with matchup: ", $scope.matchupToLock
      $scope.matchupToLock.locked = locked
      Matchup.put($scope.matchupToLock.id, $scope.matchupToLock, $scope.web_state.current_week.id).then((response) ->
        $scope.savedMessage = "Saved Matchup #{response.data.away_team.name} vs. #{response.data.home_team.name} - Locked = #{response.data.locked}"
      )

    # Modal
    $scope.open = (size) ->
      modalInstance = $modal.open(
        templateUrl: "confirmAdvanceWeekModal.html"
        controller: ModalInstanceCtrl
      )
      modalInstance.result.then (() ->
        $scope.advance_week()
      ), ->
        console.log("Modal dismissed at: " + new Date())

    ModalInstanceCtrl = ($scope, $modalInstance) ->
      console.log("In ModalInstanceCtrl")

      $scope.ok = ->
        $modalInstance.close()

      $scope.cancel = ->
        $modalInstance.dismiss("cancel")


  ]