angular.module('kopool').factory 'NflTeam', ($resource) ->
  #./nfl_teams/:id.json
  $resource('http://localhost:3000/nfl_teams/:id.json', {id: '@id'}, { save: { method: 'PATCH', url: './nfl_teams/:id.json' }, new: { method: 'POST', url: './nfl_teams.json' }, delete: { method: 'DELETE', url: './nfl_teams/:id.json' } })

#, delete: { method: 'DELETE', url: './nfl_teams/:id.json' }