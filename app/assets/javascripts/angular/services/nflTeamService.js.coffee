angular.module('kopool').factory 'NflTeam', ($resource) ->
  $resource('./nfl_teams/:id.json', {}, { save: { method: 'PATCH', url: './nfl_teams/:id.json' }})

  # Why the hell isn't the PATCH sending the ID?
  # url: './nfl_teams/:id.json'}

  # $scope.nfl_teams = NflTeam.query()


# Never got this to work:
  # class NflTeam
  #   constructor: (nflTeamId) ->
  #     console.log("(service.NflTeam.Constructor)")
  #     @service = $resource('./nfl_teams/:id',
  #         {nfl_team_id: nflTeamId, id: '@id'})

  #   create: (attrs) ->
  #     console.log("(service.NflTeam.create)")
  #     new @service(nflTeam: attrs).$save (nflTeam) ->
  #       attrs.id = nflTeam.id
  #     attrs

  #   all: ->
  #     console.log("(Service.NflTeam.all)")
  #     @service.query()

  #   testMethod: ->
  #     consold.log("ServiceNflTeam Test Method")

  #   # To get all nflteams:
  #   # $scope.nflTeams = NflTeam().all
