angular.module('kopoolCharts', ['ngResource', 'RailsApiResource', 'ui.bootstrap', 'angularCharts'])

	.factory 'KnockoutStats', (RailsApiResource) ->
		RailsApiResource('seasons/:parent_id/season_summary', 'season_summary')

	.factory 'MainPageImage', (RailsApiResource) ->
		RailsApiResource('main_image', 'url')

	.controller 'KopoolChartsCtrl', ['$scope', '$location', '$http', '$routeParams', 'WebState', 'KnockoutStats', 'MainPageImage', 'currentUser', 'SortedPicks', ($scope, $location, $http, $routeParams, WebState, KnockoutStats, MainPageImage, currentUser, SortedPicks) ->
		
		$scope.line_chart = "line"
		$scope.line_config =
			title: "Remaining Teams"
			tooltips: true
			labels: false
			legend:
				display: false
				position: "left"
			lineLegend: "traditional" 
			colors: ['#5bc0de']

#		$scope.pie_config =
#			title: "Picks This Week"
#			tooltips: true
#			labels: false
#			colors: [
#				'#7a8288','#5bc0de','#f89406','#62c462','#ee5f5b','#3a3f44'
#			]
#			legend:
#				display: false
#				position: "left"
#			innerRadius: 0

		$scope.getWebState = () ->
			$scope.loaded = false
			WebState.get(1).then((web_state) ->
				$scope.web_state = web_state
				$scope.season_id = web_state.current_season.id
				$scope.current_path = $location.path()
				$scope.getChartData()
				$scope.loadMainImage()
			)

		$scope.getWebState()

		$scope.loadMainImage = () ->
			console.log("(KopoolChartsCtrl.loadMainImage) Looking up the main_page_image")
			MainPageImage.query().then(
				(url) ->
					console.log("(KopoolChartsCtrl.loadMainImage) *** Have your main page image ***")
					console.log(url)
					$scope.main_page_image_url = url
				(json_error_data) ->
					console.log("(KopoolChartsCtrl.loadMainImage) Cannot get main_page_image")
					$scope.error_message = json_error_data.data[0].error
			)

		$scope.getChartData = () ->
			console.log("This is the path variable at this time: " + $scope.current_path)
			if $scope.current_path == "" or $scope.current_path == "/users/sign_in" or $scope.current_path == "/" 
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
					final_data = $scope.splitTeams(sorted_picks)

					$scope.pie_data = final_data
					$scope.loaded = true
					new Chartkick.PieChart("pie-chart", $scope.pie_data, {legend: "bottom",library: {plugins: {legend: {labels: {color: '#b9b85f'}}}}});
					(json_error_data) ->
						console.log("(PoolEntriesCtrl.getSortedPicks) Cannot get sorted picks")
						$scope.error_message = json_error_data.data[0].error
					)

		$scope.$on 'auth-login-success', ((event) ->
			console.log("(KopoolChartsCtrl) Caught auth-login-success broadcasted event!!")
			$scope.getWebState()
		)

		$scope.splitTeams = (sorted_picks) ->
			if sorted_picks.length > 7
				initial = sorted_picks.slice(0, 7)
				remaining = sorted_picks.slice(7, sorted_picks.length)
				others_sum = remaining.reduce((sum, team) ->
					sum + team[1]
				, 0)
				others = ['Others', others_sum]
				initial.push(others)
				initial
			else
				sorted_picks
	]
