angular.module('Home', ['ngResource', 'RailsApiResource'])

  .factory 'WebState', (RailsApiResource) ->
      RailsApiResource('admin/web_states', 'webstate')

  .factory 'PoolEntriesThisSeason', (RailsApiResource) ->
    RailsApiResource('seasons/:parent_id/season_results', 'pool_entries')

  .controller 'HomeCtrl', ['$scope', '$location', 'currentUser', 'WebState', 'PoolEntriesThisSeason', 'Week', ($scope, $location, currentUser, WebState, PoolEntriesThisSeason, Week) ->
    $scope.controller = 'HomeCtrl'
    console.log("(HomeCtrl)")

    $scope.web_state = WebState.get(1).then((web_state) ->
      $scope.web_state = web_state
      $scope.reload_week()
    )

    $scope.reload_week = () ->
      $scope.week = Week.get($scope.web_state.week_id).then((week) ->
        $scope.week = week
        $scope.open_for_picks = week.open_for_picks
        console.log("Reloaded week")
      )

    PoolEntriesThisSeason.nested_query(1).then((pool_entries) ->
      $scope.pool_entries = pool_entries
      $scope.getActivePoolEntries()
      console.log("*** Have pool entries ***")
    )

    $scope.getActivePoolEntries = () ->
      $scope.active_pool_entries = []
      for pool_entry in $scope.pool_entries
        if pool_entry.knocked_out == false
          $scope.active_pool_entries.push(pool_entry)
      $scope.active_pool_entries_count = $scope.active_pool_entries.length
      $scope.getTotalPot()

    $scope.getTotalPot = () ->
      $scope.total_pot = $scope.active_pool_entries_count * 50
      console.log("Calculated total pot")

    $scope.username = ->
      currentUser.username

    $scope.authorized = ->
      currentUser.authorized

    $scope.display_authorized = ->
      if currentUser.authorized
        "You are currently authorized as " + currentUser.username
      else
        "Please Sign-in at the top or Register"


    # Just demonstrating an alternate means of navigation.  Better to use anchor tags.
    $scope.go = ( path ) ->
      $location.path( path )

  ]