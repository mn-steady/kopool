angular.module('kopoolCharts', ['ngResource', 'RailsApiResource', 'ui.bootstrap'])

	.factory 'KnockoutStats', (RailsApiResource) ->
		RailsApiResource('seasons/:parent_id/season_summary', 'season_summary')

	.controller 'KopoolChartsCtrl', ['$scope', '$location', '$http', '$routeParams', 'WebState', ($scope, $location, $http, $routeParams, WebState) ->
		

		$scope.getWebState = () ->
			WebState.get(1).then((web_state) ->
				$scope.web_state = web_state
				$scope.season_id = web_state.current_week.season.id
				$scope.getSeasonSummary()
			)

		$scope.getWebState()

		$scope.getSeasonSummary = () ->
			console.log("(KopoolChartsCtrl) getting Season Summary")
			KnockoutStats.nested_query($scope.season_id).then((summary_info) ->
				console.log("(KopoolChartsCtrl) returned with season summary_info")
			)

	]