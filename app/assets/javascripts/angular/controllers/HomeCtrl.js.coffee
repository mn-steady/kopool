@kopool.controller 'HomeCtrl', ['$scope', '$location', 'currentUser', ($scope, $location, currentUser) ->
  $scope.controller = 'HomeCtrl'

  console.log("(HomeCtrl)")

  $scope.username = ->
    currentUser.username

  $scope.authorized = ->
    currentUser.authorized

  # Just demonstrating an alternate means of navigation.  Better to use anchor tags.
  $scope.go = ( path ) ->
    $location.path( path )

]