#= require spec_helper

describe 'MatchupsController Controller', ->

  beforeEach ->
    @currentController = 'MatchupsCtrl'

    @http.when("GET", "http://localhost:3000/admin/web_states/1.json").respond([{}, {}, {}]);
    @http.when("GET", "http://localhost:3000/weeks/undefined/matchups.json").respond([{}, {}, {}]);
    @controller('MatchupsCtrl', { $scope: @scope, $location: @location })


  describe 'MatchupsCtrl', ->
    it 'opens up the Matchups controller', ->
      expect(@scope.controller).toBe(@currentController)

  #     @controller('MatchupsCtrl', { $scope: @scope })
  #     # @Task = @model('Task')
  #     # @tasks = [new @Task({ id: 1, name: 'first task' })]

  #     # @http.whenGET('/api/tasks').respond(200, @tasks)
  #     # @http.flush()
