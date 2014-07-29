angular.module('user', ['RailsApiResource'])


  .factory('currentUser', ($cookieStore) ->
    {
      # token:        $cookieStore.get('token')
      # WARNING: Do not save admin status in the Cookie due to possible tampering. You lose admin status on refresh
      username:     $cookieStore.get('username')
      password:     ''
      authorized:   false
      admin:        false
      reset: ->
        # @token =    $cookieStore.get('token')
        @username = $cookieStore.get('username')
    }
  )


  .factory 'Tokens', (RailsApiResource) ->
    RailsApiResource('tokens')


  .constant('AUTH_EVENTS', {
    loginSuccess:     'auth-login-success'
    loginFailed:      'auth-login-failed'
    logoutSuccess:    'auth-logout-success'
    sessionTimeout:   'auth-session-timeout'
    notAuthenticated: 'auth-not-authenticated'
  })


  .factory('AuthService', ($rootScope, $cookieStore, currentUser, Tokens, AUTH_EVENTS) ->
    return {
      login: (currentUser) ->
        console.log ("(user.AuthService.login) username=" + currentUser.username)
        tokenRequest = {email: currentUser.username, password: currentUser.password}
        currentUser.password = ''

        console.log("*** DO NOT USE THIS until switch to token-based ***")

        # return Tokens.query(tokenRequest).then( (token) ->
        #   console.log("Back from getting token")

        #   if token.token?
        #     currentUser.token = token.token
        #     $rootScope.$broadcast(AUTH_EVENTS.loginSuccess)

        #   else
        #     $rootScope.$broadcast(AUTH_EVENTS.loginFailed)
        # )


      isAuthenticated: ->
        # !!"" === false // empty string is falsy
        # !!"foo" === true  // non-empty string is truthy
        # !!"false" === true  // ...even if it contains a falsy value
        # console.log ("(user.AuthService.isAuthenticated) currentUser.username=" + currentUser.username)
        # console.log ("(user.AuthService.isAuthenticated) cookieStore.username=" + $cookieStore.get('username'))
        return !!currentUser.username && !!$cookieStore.get('username')


      updateCookies: ->
        console.log("(AuthService.updateCookies)")
        $cookieStore.put('username', currentUser.username)

      endSession: ->
        $cookieStore.remove('username')
        currentUser.reset()
    }
  )


  .controller('LoginController', ($scope, $location, currentUser, AUTH_EVENTS, AuthService) ->
    console.log "(user.LoginController)"
    AuthService.endSession()
    console.log currentUser

    $scope.currentUser = currentUser
    $location.url('/dashboard') if AuthService.isAuthenticated()


    $scope.login = (currentUser) ->
      console.log("(user.LoginController) .login")
      AuthService.login(currentUser)


    $scope.$on(AUTH_EVENTS.loginSuccess, ->
      console.log('(LoginController) login success event')
      $scope.currentUser.admin    = currentUser.admin
      AuthService.updateCookies()

      $location.url('/dashboard')
    )


    $scope.$on(AUTH_EVENTS.loginFailed, ->
      console.log('(LoginController) login failed event')
      $scope.currentUser.token    = undefined
      $scope.currentUser.username = undefined
      $scope.currentUser.password = undefined
      $scope.currentUser.admin    = false
      AuthService.updateCookies()
    )

  )

