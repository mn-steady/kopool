angular.module('Home', ['ngResource', 'RailsApiResource', 'user'])

  .factory 'WebState', (RailsApiResource) ->
      RailsApiResource('admin/web_states', 'webstate')

  .factory 'PoolEntriesThisSeason', (RailsApiResource) ->
    RailsApiResource('seasons/:parent_id/season_results', 'pool_entries')

  .factory 'SeasonWeeks', (RailsApiResource) ->
      RailsApiResource('seasons/:parent_id/weeks', 'weeks')

  .controller 'HomeCtrl', ['$scope', '$location', 'currentUser', 'WebState', 'PoolEntriesThisSeason', 'SeasonWeeks', ($scope, $location, currentUser, WebState, PoolEntriesThisSeason, SeasonWeeks) ->
    $scope.controller = 'HomeCtrl'
    console.log("(HomeCtrl)")

    $scope.total_pot = 0
    $scope.pool_entries = []
    $scope.active_pool_entries = []
    $scope.active_pool_entries_count = 0
    $scope.weeks = {}

    $scope.web_state =
      id: 0
      week_id: 0
      broadcast_message: "...Please Login..."
      current_week:
        id: 0
        week_number: 0
        open_for_picks: false
        season:
          id: 0
          year: 0
          name: "...Please Login..."
          open_for_registration: false


    WebState.get(1).then((web_state) ->
      console.log("Got a web state")
      $scope.web_state = web_state
      $scope.week = web_state.current_week
      $scope.open_for_picks = web_state.current_week.open_for_picks
      if $scope.authorized()
        console.log("*** authorized ***")
        $scope.reload_pool_entries()
        $scope.load_season_weeks()
      else
        console.log("** Current user is not authorized - no pool entries **")
    )

    $scope.reload_pool_entries = () ->
      console.log("(reload_pool_entries)")
      PoolEntriesThisSeason.nested_query(1).then((pool_entries) ->
        $scope.pool_entries = pool_entries
        $scope.getActivePoolEntries()
        console.log("(reload_pool_entries) Have pool entries")
      )

    $scope.getActivePoolEntries = () ->
      console.log("(getActivePoolEntries)")
      for pool_entry in $scope.pool_entries
        if pool_entry.knocked_out == false
          $scope.active_pool_entries.push(pool_entry)
      $scope.active_pool_entries_count = $scope.active_pool_entries.length
      $scope.getTotalPot()

    $scope.load_season_weeks = () ->
      console.log("(load_season_weeks)")
      SeasonWeeks.nested_query($scope.web_state.current_week.season.id).then((weeks) ->
        console.log("(load_season_weeks) *** Have All Weeks ***")
        $scope.weeks = weeks
      )

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

    $scope.display_battle_summary = ->
      if currentUser.authorized
        "There are currently " + $scope.active_pool_entries_count + " teams remaining in the ring, battling for a sum of $" + $scope.total_pot + "!"
      else
        "Sign-in for the weekly summary"

    # Just demonstrating an alternate means of navigation.  Better to use anchor tags.
    $scope.go = ( path ) ->
      $location.path( path )

  ]