angular.module('navbar', ['ngResource', 'RailsApiResource'])

  .controller 'navbarCtrl', ['$scope', '$location', '$http', '$cookieStore', ($scope, $location, $http, $cookieStore) ->

    $scope.controller = 'navbarCtrl'
    console.log("In navbarCtrl")
    $scope.login_user = {email: null, password: null}
    $scope.login_error = {message: null, errors: {}}

    $scope.login_logout = ->
      console.log("(navbarCtrl.login_logout)")
      if $scope.current_user?
        console.log("...Logging OUT")
        $scope.logout()
      else
        console.log("...Logging IN")
        $scope.login()

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
          console.log("(navBarCtrl.submit.success)")
          $scope.save_user_data(data.user)
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

    $scope.save_user_data = (user_data) ->
      console.log("(navbarCtrl.save_user_data)")
      $cookieStore.put('authorized', true)
      $cookieStore.put('username', user_data.email)
      console.log("(navbarCtrl.save_user_data) saved username:" + $cookieStore.get('username'))
      $scope.current_user = user_data
      $scope.current_user.authorized = true
      # Clear out the UI fields
      $scope.login_user.email = null
      $scope.login_user.password = null
      console.log("Have set current_user.authorized")
      return

    $scope.display_name = ->
      if $scope.current_user?
        $scope.current_user.email
      else
        "KO Pool"

    $scope.button_sign_in_or_out = ->
      if $scope.current_user?
        "Sign Out"
      else
        "Sign In"

    # Just demonstrating an alternate means of navigation.  Better to use anchor tags.
    $scope.go = ( path ) ->
      $location.path( path )

  ]