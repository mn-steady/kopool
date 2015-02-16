angular.module('kopool').service('seasonDataService', ['$http', ($http) ->
  season_summary: (season_id) ->
  	season_summary = {}
  	@season_id = season_id
  	$http.get('seasons/:season_id/season_summary', {season_id: @season_id}).then(response) ->
  		season_summary = response
])