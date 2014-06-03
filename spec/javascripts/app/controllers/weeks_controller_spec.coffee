#= require spec_helper

describe 'Weeks Controller', ->

  beforeEach ->
    @currentController = 'WeeksCtrl'

    @http.when("GET", "http://localhost:3000/seasons/1/weeks.json").respond([{}, {}, {}]);
    @controller('WeeksCtrl', { $scope: @scope, $location: @location })


  describe 'WeeksCtrl', ->
    it 'opens up the Weeks controller', ->
      expect(@scope.controller).toBe(@currentController)

