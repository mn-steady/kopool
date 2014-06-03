@kopool.controller 'HomeCtrl', ['$scope', '$location', '$cookieStore', ($scope, $location, $cookieStore) ->
  $scope.controller = 'HomeCtrl'

  console.log("(HomeCtrl)")

  $scope.username = ->
    $cookieStore.get('username')

  $scope.authorized = ->
    $cookieStore.get('authorized')


  # Just demonstrating an alternate means of navigation.  Better to use anchor tags.
  $scope.go = ( path ) ->
    $location.path( path )

]