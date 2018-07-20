angular.module('Home', ['ngResource', 'RailsApiResource', 'user'])

  .factory 'WebState', (RailsApiResource) ->
      RailsApiResource('admin/web_states', 'webstate')

  .factory 'SeasonWeeks', (RailsApiResource) ->
      RailsApiResource('seasons/:parent_id/weeks', 'weeks')

  .controller 'HomeCtrl', ['$scope', '$location', 'currentUser', 'AuthService', 'WebState', 'SeasonWeeks', '$http', ($scope, $location, currentUser, AuthService, WebState, SeasonWeeks, $http) ->
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
      $http.get("/seasons/#{$scope.web_state.current_season.id}/season_knockout_counts", {params: {format: 'json'}}).then((pool_entry_response) ->
        console.log("(loadPoolEntries) returned with pool_entries", pool_entry_response)
        $scope.pool_entry_counts = pool_entry_response['data']
        if $scope.pool_entry_counts['true']
          $scope.total_entry_count = $scope.pool_entry_counts['false'] + $scope.pool_entry_counts['true']
        else
          $scope.total_entry_count = $scope.pool_entry_counts['false']
        console.log "$scope.pool_entry_counts", $scope.pool_entry_counts
        $scope.getActivePoolEntries()
        console.log("(loadPoolEntries) Have pool entries")
      )

    $scope.getActivePoolEntries = () ->
      $scope.active_pool_entries_count = $scope.pool_entry_counts['false']
      $scope.getTotalPot()

    $scope.getTotalPot = () ->
      fullPot = (($scope.total_entry_count - 6) * 50)
      $scope.total_pot = (fullPot - 1050)
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