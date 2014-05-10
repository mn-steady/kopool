@kopool.controller 'navbarCtrl', ['$scope', '$location', ($scope, $location) ->
  $scope.controller = 'navbarCtrl'

  $scope.username = "admin@example.com"
  $scope.password = "password"

  # Just demonstrating an alternate means of navigation.  Better to use anchor tags.
  $scope.go = ( path ) ->
    $location.path( path )

]