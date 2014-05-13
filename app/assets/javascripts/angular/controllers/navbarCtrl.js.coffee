@kopool.controller 'navbarCtrl', ['$scope', '$location', '$http', ($scope, $location, $http) ->
  $scope.controller = 'navbarCtrl'

  $scope.login_user = {email: "admin@example.com", password: "password"}

  $scope.login = ->
    console.log("(navbarCtrl.login)")
    $http.post('../users/sign_in.json', {user: {email: $scope.login_user.email, password: $scope.login_user.password}})

  $scope.logout = ->
    $http({method: 'DELETE', url: '../users/sign_out.json', data: {}})


  # Just demonstrating an alternate means of navigation.  Better to use anchor tags.
  $scope.go = ( path ) ->
    $location.path( path )

]