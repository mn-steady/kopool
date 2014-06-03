angular.module('Matchups', ['ngResource', 'RailsApiResource'])

	.factory 'Matchup', (RailsApiResource) ->
		RailsApiResource('weeks/:parent_id/matchups', 'matchups')

	.controller 'MatchupsCtrl', ['$scope', '$location', '$http', '$routeParams', 'Matchup', 'NflTeam', ($scope, $location, $http, $routeParams, Matchup, NflTeam) ->
		$scope.controller = 'MatchupsCtrl'
		console.log("MatchupsCtrl")
		console.log("$location:" + $location)
		$scope.matchups = []

		week_id = $routeParams.week_id

		NflTeam.query().then((nfl_teams) ->
      $scope.nfl_teams = nfl_teams
      console.log("*** Have nfl_teams***")
    )

		Matchup.nested_query(week_id).then((matchups) ->
      $scope.matchups = matchups
      console.log("*** Have matchups***")
    )

		$scope.selectMatchup = (matchup) ->
			$scope.selectedMatchup = matchup

		$scope.isSelected = (matchup) ->
			$scope.selectedMatchup == matchup
	]