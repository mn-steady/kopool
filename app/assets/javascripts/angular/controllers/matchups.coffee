angular.module('Matchups', ['ngResource', 'RailsApiResource'])
	.factory 'Matchup', (RailsApiResource) ->
		RailsApiResource('matchups', 'matchups')

	.controller 'MatchupsCtrl', ['$scope', '$location', '$http', '$routeParams', 'Matchup', ($scope, $location, $http, $routeParams, Matchup) ->
		$scope.controller = 'MatchupsCtrl'
		console.log("MatchupsCtrl")
		console.log("$location:" + $location)
		$scope.matchups = []

		$http.get("./matchups.json").success((data) ->
			console.log("matchup data:" + data)
			$scope.matchups = data
		)
	]