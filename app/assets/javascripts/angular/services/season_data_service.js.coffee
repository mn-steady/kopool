angular.module('kopool').service('seasonDataService', ['$http', ($http) ->
  season_summary: (season_id) ->
  	season_summary = {}
  	$http.get('seasons/:season_id/season_summary').then(response) ->
  		season_summary = response
])

RailsApiResource('seasons/:parent_id/season_summary', 'season_summary')