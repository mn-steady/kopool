#= require spec_helper

describe 'homeController', ->

  ctrl = {}
  scope = {}
  SeasonDataService = {}
  $httpBackend = {}

  beforeEach inject ($rootScope, $controller, seasonDataService, _$httpBackend_) ->
    scope = $rootScope.$new()
    SeasonDataService = seasonDataService
    $httpBackend = _$httpBackend_
    $httpBackend.when('GET', 'http://localhost:3000/admin/web_states/1.json').respond({"id":1,"week_id":4,"broadcast_message":"Wow this new UI is pretty awesome!","created_at":"2014-12-08T21:39:43.000-05:00","updated_at":"2014-12-17T22:08:35.000-05:00","current_week":{"id":4,"week_number":4,"open_for_picks":false,"season":{"id":1,"year":2014,"name":"2014 Season","open_for_registration":false}}})

    ctrl = $controller('homeController', { $scope: scope })

    spyOn(SeasonDataService, 'season_summary').and.returnValue([{"x":"1","y":[9]},{"x":"2","y":[6]},{"x":"3","y":[4]},{"x":"4","y":[3]}])

  describe 'initialization', ->
    it 'gets the WebState', ->
      $httpBackend.expectGET('http://localhost:3000/admin/web_states/1.json')
      expect(scope.season_id).toEqual(1)
      $httpBackend.verifyNoOutstandingExpectation()
      # expect(scope.chart_data).toEqual({"series":"Active Teams","data":[{"x":"1","y":[9]},{"x":"2","y":[6]},{"x":"3","y":[4]},{"x":"4","y":[3]}]})



