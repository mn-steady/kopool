angular.module('kopool').factory 'NflTeam', ($resource) ->
  class NflTeam
    constructor: (nflTeamId) ->
      @service = $resource('/nfl_teams/:id',
          {nfl_team_id: nflTeamId, id: '@id'})

    create: (attrs) ->
      new @service(nflTeam: attrs).$save (nflTeam) ->
        attrs.id = nflTeam.id
      attrs

    all: ->
      @service.query()

    # To get all nflteams:
    # $scope.nflTeams = NflTeam().all
