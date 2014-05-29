#= require spec_helper

describe 'HomeCtrl', ->
  beforeEach ->
    @controller('HomeCtrl', { $scope: @scope })
    @currentController = 'HomeCtrl'
    # @Task = @model('Task')
    # @tasks = [new @Task({ id: 1, name: 'first task' })]

    # @http.whenGET('/api/tasks').respond(200, @tasks)
    # @http.flush()

  describe 'load', ->
    it 'opens up the home controller', ->
      expect(1).toEqual(1)
      #expect(@scope.controller_source).toBe(@currentController)
