@kopool.controller 'HomeCtrl', ['$scope', '$location', ($scope, $location) ->
  $scope.controller = 'HomeCtrl'


  # Just demonstrating an alternate means of navigation.  Better to use anchor tags.
  $scope.go = ( path ) ->
    $location.path( path )

]