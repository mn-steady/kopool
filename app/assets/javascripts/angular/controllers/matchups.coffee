angular.module('Matchups', ['ngResource', 'RailsApiResource'])

	.factory 'Matchup', (RailsApiResource) ->
		RailsApiResource('weeks/:parent_id/matchups', 'matchups')

	.controller 'MatchupsCtrl', ['$scope', '$location', '$http', '$routeParams', 'Matchup', ($scope, $location, $http, $routeParams, Matchup) ->
		$scope.controller = 'MatchupsCtrl'
		console.log("MatchupsCtrl")
		console.log("$location:" + $location)
		$scope.matchups = []

		week_id = $routeParams.week_id

		Matchup.nested_query(week_id).then((matchups) ->
      $scope.matchups = matchups
      console.log("*** Have matchups***")
    )

		$scope.selectMatchup = (matchup) ->
			$scope.selectedMatchup = matchup

		$scope.isSelected = (matchup) ->
			$scope.selectedMatchup == matchup
	]