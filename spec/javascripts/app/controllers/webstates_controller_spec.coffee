#= require spec_helper

describe 'WebStates Controller', ->

  beforeEach ->
    @currentController = 'WebStatesCtrl'

    @http.when("GET", "http://localhost:3000/commissioner/web_states/1.json").respond([{}, {}, {}]);
    @controller('WebStatesCtrl', { $scope: @scope, $location: @location })


  describe 'WebStatesCtrl', ->
    it 'opens up the Web States controller', ->
      expect(@scope.controller).toBe(@currentController)
