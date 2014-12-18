angular.module('navbar', ['ngResource', 'RailsApiResource', 'user'])

  .controller 'navbarCtrl', ['$scope', '$rootScope', '$location', '$http', 'currentUser', 'AuthService', '$cookieStore', ($scope, $rootScope, $location, $http, currentUser, AuthService, $cookieStore) ->

    $scope.controller = 'navbarCtrl'
    console.log("In navbarCtrl")
    $scope.login_user = {email: null, password: null}
    $scope.login_error = {message: null, errors: {}}

    $scope.login_logout = ->
      console.log("(navbarCtrl.login_logout)")
      if AuthService.isAuthenticated()
        console.log("(navbarCtrl.login_logout) Currently Authenticated so Logging OUT")
        $scope.logout()
      else
        console.log("(navbarCtrl.login_logout) Logging IN with username:" + $scope.login_user.email)
        $scope.login()

    $scope.login = ->
      console.log("(navbarCtrl.login)")
      $scope.submit
        method: "POST"
        url: "../tokens.json"
        data:
          user:
            email: $scope.login_user.email
            password: $scope.login_user.password
        error_entity: $scope.login_error

    $scope.logout = ->
      console.log("(navbarCtrl.logout)")
      currentUser.authorized = false
      currentUser.username = ''
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
          if parameters.method == "DELETE"
            $scope.clear_user_loggedout(data.user)
          else
            # TODO (C1) - Bug in our rails controller... It is, for some reason, defaulting to user 1 even if I
            # login with nonadmin@example.com.  You can see us asking for nonadmin and it returning the data on admin
            # may be due to overridden xsrf stuff..  This was "resolved" by fixing the app to consistently examine the AuthService
            #
            # VERY MUCH DISCUSSION HERE:
            # http://stackoverflow.com/questions/11845500/rails-devise-authentication-csrf-issue
            #
            # AND HERE:
            # https://gist.github.com/jwo/1255275
            $scope.save_user_data(data)
        else
          console.log("Simple unauthorized user scenario")
          $rootScope.$broadcast('auth-login-failed')
          if data.error
            parameters.error_entity.message = data.error
          else
            parameters.error_entity.message = "Success, but with an unexpected success code, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: " + JSON.stringify(data)
        return
      ).error (data, status) ->
        console.log("Error in navbarCtrl.submit")
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

    $scope.clear_user_loggedout = (user_data) ->
      console.log("(navbarCtrl.clear_user_loggedout)")
      currentUser.authorized = false
      currentUser.username = ''
      currentUser.admin = false
      console.log("(navbarCtrl.clear_user_loggedout) cleared username:" + currentUser.username)
      AuthService.endSession()

      # Clear out the UI fields
      $scope.login_user.email = null
      $scope.login_user.password = null

      # Return to main page
      $location.path "/"
      return

    $scope.save_user_data = (data) ->
      console.log("(navbarCtrl.save_user_data)")
      currentUser.authorized = true
      currentUser.admin = data.user.admin
      currentUser.username = data.user.email
      currentUser.token = data.token
      AuthService.updateCookies()
      $rootScope.$broadcast('auth-login-success')
      console.log("(navbarCtrl.save_user_data) saved username:" + currentUser.username)

      # Clear out the UI fields
      $scope.login_user.email = null
      $scope.login_user.password = null
      return

    $scope.isSignedIn = ->
      if AuthService.isAuthenticated()
        true

    $scope.display_name = ->
      if AuthService.isAuthenticated()
        currentUser.username
      else
        "KO Pool"

    $scope.button_sign_in_or_out = ->
      if AuthService.isAuthenticated()
        "Sign Out"
      else
        "Sign In"

    # Just demonstrating an alternate means of navigation.  Better to use anchor tags.
    $scope.go = ( path ) ->
      $location.path( path )

  ]