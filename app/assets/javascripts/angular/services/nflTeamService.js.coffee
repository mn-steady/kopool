angular.module('kopool').factory 'xxx_old_NflTeam', ($resource) ->
  #./nfl_teams/:id.json
  $resource('http://localhost:3000/nfl_teams/:id.json', {id: '@id'}, { save: { method: 'PATCH', url: './nfl_teams/:id.json' }, new: { method: 'POST', url: './nfl_teams.json' }, remove: { method: 'DELETE', url: './nfl_teams/:id.json' } })

#, delete: { method: 'DELETE', url: './nfl_teams/:id.json' }