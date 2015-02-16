angular.module('kopool').controller('homeController', ['$scope', 'seasonDataService', 'WebState', ($scope, seasonDataService, WebState) ->

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
		WebState.get(1).then((web_state) ->
			$scope.web_state = web_state
			$scope.season_id = web_state.current_week.season.id
			$scope.current_path = $location.path()
			$scope.getSeasonSummary()
		)

	$scope.getWebState()

	$scope.getSeasonSummary = () ->
		console.log("(homeController) getting Season Summary")
		seasonDataService.season_summary($scope.season_id).then((summary_info) ->
			console.log("(homeController) returned with season summary_info")
			$scope.chart_values = summary_info
			$scope.series = "Active Teams"
			$scope.chart_data = {"series":[$scope.series],"data":$scope.chart_values}
			console.log("Setting loaded flag to true for the chart")
			$scope.loaded = true
		)
])