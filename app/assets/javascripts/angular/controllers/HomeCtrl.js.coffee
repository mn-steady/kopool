angular.module('Home', ['ngResource', 'RailsApiResource', 'user'])

  .factory 'WebState', (RailsApiResource) ->
      RailsApiResource('admin/web_states', 'webstate')

  .factory 'PoolEntriesThisSeason', (RailsApiResource) ->
    RailsApiResource('seasons/:parent_id/season_results', 'pool_entries')

  .factory 'SeasonWeeks', (RailsApiResource) ->
      RailsApiResource('seasons/:parent_id/weeks', 'weeks')

  .controller 'HomeCtrl', ['$scope', '$location', 'currentUser', 'AuthService', 'WebState', 'PoolEntriesThisSeason', 'SeasonWeeks', ($scope, $location, currentUser, AuthService, WebState, PoolEntriesThisSeason, SeasonWeeks) ->
    $scope.controller = 'HomeCtrl'
    console.log("(HomeCtrl)")

    $scope.total_pot = 0
    $scope.pool_entries = []
    $scope.active_pool_entries = []
    $scope.active_pool_entries_count = 0
    $scope.weeks = {}
    $scope.session_message = null
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


    # Action Functions

    $scope.getWebState = () ->
      WebState.get(1).then((web_state) ->
        console.log("(HomeCtrl.getWebState) Back from the WebState lookup")
        $scope.web_state = web_state
        $scope.loadPoolEntries()
      )

    $scope.loadPoolEntries = () ->
      console.log("(loadPoolEntries)")
      if $scope.pool_entries.length == 0
        PoolEntriesThisSeason.nested_query($scope.web_state.current_season.id).then((pool_entries) ->
          console.log("(loadPoolEntries) returned with pool_entries ="+pool_entries)
          $scope.pool_entries = pool_entries
          $scope.getActivePoolEntries()
          console.log("(loadPoolEntries) Have pool entries")
        )
      else
        console.log("(loadPoolEntries) ALREADY LOADED")

    $scope.getActivePoolEntries = () ->
      console.log("(getActivePoolEntries)")
      for pool_entry in $scope.pool_entries
        if pool_entry.knocked_out == false
          $scope.active_pool_entries.push(pool_entry)
      $scope.active_pool_entries_count = $scope.active_pool_entries.length
      $scope.getTotalPot()

    $scope.getTotalPot = () ->
      $scope.total_pot = ($scope.pool_entries.length - 5) * 50
      console.log("Calculated total pot")
      
    # Main Controller Actions

    $scope.getWebState()

    $scope.$on 'auth-login-success', ((event) ->
      console.log("(HomeCtrl) Caught auth-login-success broadcasted event!!")
      $scope.session_message = null
      $scope.getWebState()
    )

    $scope.$on 'auth-login-failed', ((event) ->
      console.log("(HomeCtrl) Caught auth-login-failed broadcasted event!!")
      $scope.session_message = "Incorrect username or password. Please try again."
    )


    # Display and utility functions

    $scope.is_authorized = ->
      !!AuthService.isAuthenticated()

    $scope.is_admin = ->
      currentUser.admin

    $scope.display_authorized = ->
      if AuthService.isAuthenticated()
        "You are currently authorized as " + currentUser.username
      else
        "Please Register below"

    $scope.display_pot_amount = ->
      if !!AuthService.isAuthenticated() then $scope.total_pot else ''

    $scope.display_round_number = ->
      if AuthService.isAuthenticated()
        $scope.web_state.current_week.week_number

    $scope.register_button_text = () ->
      if AuthService.isAuthenticated()
        "Add Pool Entries for #{$scope.web_state.current_season.name} »"
      else
        "Register »"

    # Just demonstrating an alternate means of navigation.  Better to use anchor tags.
    $scope.go = ( path ) ->
      $location.path( path )

  ]