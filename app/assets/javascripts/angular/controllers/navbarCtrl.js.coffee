@kopool.controller 'navbarCtrl', ['$scope', '$location', '$http', '$cookieStore', ($scope, $location, $http, $cookieStore) ->
  $scope.controller = 'navbarCtrl'

  console.log("In navbarCtrl")

  $scope.login_user = {email: null, password: null}
  $scope.login_error = {message: null, errors: {}}

  $scope.login = ->
    console.log("(navbarCtrl.login)")
    $scope.submit 
      method: "POST"
      url: "../users/sign_in.json"
      data: 
        user: 
          email: $scope.login_user.email
          password: $scope.login_user.password
      success_message: "You have been logged in! Good luck!"
      error_entity: $scope.login_error

  $scope.logout = ->
    $scope.submit
      method: "DELETE"
      url: "../users/sign_out.json"
      data: null
      success_message: "You have logged out."
      error_entity: $scope.login_error
  
  $scope.submit = (parameters) ->
    $scope.reset_messages()

    $http(
      method: parameters.method
      url: parameters.url
      data: parameters.data
    ).success((data, status) ->
      if status is 201 or status is 204 or status is 200
        parameters.error_entity.message = parameters.success_message
        console.log("Back to submit function")
        $scope.reset_users(data.user)
      else
        if data.error
          parameters.error_entity.message = data.error
        else
          parameters.error_entity.message = "Success, but with an unexpected success code, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: " + JSON.stringify(data)
      return
    ).error (data, status) ->
      if status is 422
        parameters.error_entity.errors = data.errors
      else
        if data.error
          parameters.error_entity.message = data.error
        else
          parameters.error_entity.message = "Unexplained error, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: " + JSON.stringify(data)
      return
    return

  $scope.reset_messages = ->
    $scope.login_error.message = null
    $scope.login_error.errors = {}
    return

  $scope.reset_users = (current_user) ->
    $cookieStore.put('loggedin', 'true')
    $scope.current_user = current_user
    $scope.login_user.email = null
    $scope.login_user.password = null
    return

  $scope.display_name = ->
    console.log "In display name function"
    console.log $cookieStore.get('loggedin')
    if $scope.current_user?
      $scope.current_user.email
    else
      "KO Pool"

  # Just demonstrating an alternate means of navigation.  Better to use anchor tags.
  $scope.go = ( path ) ->
    $location.path( path )

]