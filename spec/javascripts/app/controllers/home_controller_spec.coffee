#= require spec_helper

describe 'Home Controller', ->

  # NOTE: Keeping this syntax as a sample, but you don't have to inject these! Done for you in spec_helper.coffee
  beforeEach inject ($rootScope, $location, $controller) ->
    @scope       = $rootScope.$new()
    @location    = $location

    @currentController = 'HomeCtrl'
    @http.when("GET", "http://localhost:3000/admin/web_states/1.json").respond([{}, {}, {}]);
    $controller('HomeCtrl', { $scope: @scope, $location: @location })


  describe 'HomeCtrl', ->
    it 'passes a simple jasmine test', ->
      expect(1).toEqual(1)

    it 'opens up the home controller', ->
      expect(@scope.controller).toBe(@currentController)


