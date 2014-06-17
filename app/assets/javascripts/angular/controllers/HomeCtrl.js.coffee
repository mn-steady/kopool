@kopool.controller 'HomeCtrl', ['$scope', '$location', 'currentUser', ($scope, $location, currentUser) ->
  $scope.controller = 'HomeCtrl'

  console.log("(HomeCtrl)")

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