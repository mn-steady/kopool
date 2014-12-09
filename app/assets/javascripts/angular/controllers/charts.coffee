angular.module('kopoolCharts', ['ngResource', 'RailsApiResource', 'ui.bootstrap', 'angularCharts'])

	.factory 'KnockoutStats', (RailsApiResource) ->
		RailsApiResource('seasons/:parent_id/season_summary', 'season_summary')

	.controller 'KopoolChartsCtrl', ['$scope', '$location', '$http', '$routeParams', 'WebState', 'KnockoutStats', 'currentUser', 'SortedPicks', ($scope, $location, $http, $routeParams, WebState, KnockoutStats, currentUser, SortedPicks) ->
		
		$scope.line_chart = "line"
		$scope.line_config =
			title: "Remaining Teams"
			tooltips: true
			labels: false
			legend:
				display: false
				position: "left"
			lineLegend: "traditional" 
			colors: ['#4B0082']

		$scope.pie_config =
			title: "Picks This Week"
			tooltips: true
			labels: false
			colors: [
				'#802F64','#B6478F','#B8669B','#50103A','#4E1A3B',
				'#A13B45','#E35966','#E77F89','#65141C','#612027',
				'#428B33','#61C44D','#7DC76E','#1E5712','#26541C',
				'#809D39'	,'#B7DE56','#C4E17C','#4B6214','#4C5F20'
			]
			legend:
				display: false
				position: "left"
			innerRadius: 0

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
				$scope.getSortedPicks()

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

		$scope.getSortedPicks = () ->
			console.log("Getting SortedPicks for pie chart")
			SortedPicks.nested_query($scope.week_id).then(
				(sorted_picks) ->
					console.log("Have sorted picks")
					$scope.pie_values = []
					for pick in sorted_picks
						team_count = 
							x: pick[0] # I don't think this does anything since we are hiding the legend, but is required for the chart
							y: [pick[1]]
							tooltip: pick[0] # The tooltip is what actually shows the team name when we hide the legend
						$scope.pie_values.push(team_count)
					
					console.log("Successfully received sorted picks for the pie chart")
					$scope.series = ""
					$scope.pie_data = {"series":[$scope.series],"data":$scope.pie_values}
					$scope.loaded = true
				(json_error_data) ->
					console.log("(PoolEntriesCtrl.getSortedPicks) Cannot get sorted picks")
					$scope.error_message = json_error_data.data[0].error
			)

		$scope.$on 'auth-login-success', ((event) ->
			console.log("(KopoolChartsCtrl) Caught auth-login-success broadcasted event!!")
			$scope.getWebState()
		)

	]