angular.module('kopoolCharts', ['ngResource', 'RailsApiResource', 'ui.bootstrap', 'angularCharts'])

	.factory 'KnockoutStats', (RailsApiResource) ->
		RailsApiResource('seasons/:parent_id/season_summary', 'season_summary')

	.controller 'KopoolChartsCtrl', ['$scope', '$location', '$http', '$routeParams', 'WebState', 'KnockoutStats', 'currentUser', ($scope, $location, $http, $routeParams, WebState, KnockoutStats, currentUser) ->
		
		$scope.line_chart = "line"
		$scope.line_config =
      title: "Remaining Teams"
      tooltips: true
      labels: false
      legend:
        display: false
        position: "left"
      lineLegend: "traditional" # can be also 'traditional'
      colors: ['#4B0082']

		$scope.getWebState = () ->
			$scope.loaded = false
			if currentUser.authorized
				WebState.get(1).then((web_state) ->
					$scope.web_state = web_state
					$scope.season_id = web_state.current_week.season.id
					$scope.current_path = $location.path()
					$scope.getChartData()
				)

		$scope.getWebState()

		$scope.getChartData = () ->
			console.log("This is the path variable at this time: " + $scope.current_path)
			if $scope.current_path == "" or $scope.current_path == "/users/sign_in"
				$scope.getSeasonSummary()
			else if /weeks\/\d*\/results/.test($scope.current_path) # RegEx to see if we are on a Week's Results page
				console.log("KopoolChartsCtrl.getChartData thinks we are on a results page")
			


		$scope.getSeasonSummary = () ->
			console.log("(KopoolChartsCtrl) getting Season Summary")
			KnockoutStats.nested_query($scope.season_id).then((summary_info) ->
				console.log("(KopoolChartsCtrl) returned with season summary_info")
				$scope.chart_values = summary_info
				$scope.series = "Active Teams"
				$scope.chart_data = {"series":[$scope.series],"data":$scope.chart_values}
				console.log("Setting loaded flag to true for the chart")
				$scope.loaded = true
			)

		$scope.$on 'auth-login-success', ((event) ->
      console.log("(KopoolChartsCtrl) Caught auth-login-success broadcasted event!!")
      $scope.getWebState()
    )

	]