#= require spec_helper

describe 'NflTeams Controller', ->

  beforeEach ->
    @currentController = 'NflTeamsCtrl'

    @http.when("GET", "http://localhost:3000/nfl_teams.json").respond([{}, {}, {}]);
    @controller('NflTeamsCtrl', { $scope: @scope, $location: @location })


  describe 'NflTeamsCtrl', ->
    it 'opens up the Nfl Teams controller', ->
      expect(@scope.controller).toBe(@currentController)

  #     @controller('NflTeamsCtrl', { $scope: @scope })
  #     # @Task = @model('Task')
  #     # @tasks = [new @Task({ id: 1, name: 'first task' })]

  #     # @http.whenGET('/api/tasks').respond(200, @tasks)
  #     # @http.flush()
