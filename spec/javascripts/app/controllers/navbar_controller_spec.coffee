#= require spec_helper

describe 'Navbar Controller', ->

  beforeEach ->
    @currentController = 'navbarCtrl'
    @controller('navbarCtrl', { $scope: @scope, $location: @location })

  describe 'navbarCtrl', ->
    it 'opens up the Nav Bar controller', ->
      expect(@scope.controller).toBe(@currentController)

    it 'sets an empty login object', ->
      expect(@scope.login_user).toEqual({email: null, password: null})

    it 'displays KO Pool as name since not logged in', ->
      expect(@scope.display_name()).toEqual('KO Pool')

    it 'has sign-in on the button since not logged in', ->
      expect(@scope.button_sign_in_or_out()).toEqual('Sign In')