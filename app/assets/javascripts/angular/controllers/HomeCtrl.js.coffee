angular.module('Home', ['ngResource', 'RailsApiResource'])

  .factory 'WebState', (RailsApiResource) ->
      RailsApiResource('admin/web_states', 'webstate')

  .controller 'HomeCtrl', ['$scope', '$location', 'currentUser', 'WebState', ($scope, $location, currentUser, WebState) ->
    $scope.controller = 'HomeCtrl'
    console.log("(HomeCtrl)")

    $scope.web_state = WebState.get(1).then((web_state) ->
      $scope.web_state = web_state
    )

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