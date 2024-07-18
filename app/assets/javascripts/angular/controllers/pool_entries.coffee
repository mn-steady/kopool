angular.module('PoolEntries', ['ngResource', 'RailsApiResource'])

	.factory 'WeekResults', (RailsApiResource) ->
		RailsApiResource('weeks/:parent_id/week_results', 'pool_entries')

	.factory 'NflTeam', (RailsApiResource) ->
		RailsApiResource('nfl_teams', 'nfl_teams')

	.factory 'PickResults', (RailsApiResource) ->
		RailsApiResource('weeks/:parent_id/week_picks', 'picks')

	.factory 'SortedPicks', (RailsApiResource) ->
		RailsApiResource('weeks/:parent_id/sorted_picks', 'picks')

	.factory 'BubbleImage', (RailsApiResource) ->
		RailsApiResource('seasons/:parent_id/pool_image', 'pool')

	.controller 'PoolEntriesCtrl', ['$scope', '$location', '$http', '$routeParams', 'NflTeam', 'BubbleImage', 'WeekResults', 'PickResults', 'WebState', 'SeasonWeeks', 'SortedPicks', 'currentUser', 'AuthService', ($scope, $location, $http, $routeParams, NflTeam, BubbleImage, WeekResults, PickResults, WebState, SeasonWeeks, SortedPicks, currentUser, AuthService) ->

		week_id = parseInt( $routeParams.week_id, 10 )
		$scope.week_id = week_id
		console.log("The passed-in week's ID is: " + $scope.week_id)
		$scope.current_week = {}
		$scope.season_weeks = {}


		$scope.getWebState = () ->
			console.log("(PoolEntriesCtrl.getWebState) Looking up the WebState")
			$scope.web_state = WebState.get(1).then((web_state) ->
				console.log("(PoolEntriesCtrl.getWebState) Have WebState")
				$scope.web_state = web_state
				$scope.current_week = web_state.current_week
				$scope.open_for_picks = web_state.current_week.open_for_picks
				$scope.getNflTeams()
				$scope.load_bubble_image()
			)

		$scope.getNflTeams = () ->
			console.log("(PoolEntriesCtrl.getNflTeams) Looking up the NflTeams")
			NflTeam.query().then((nfl_teams) ->
				console.log("(PoolEntriesCtrl.getNflTeams) *** Have nfl_teams***")
				$scope.nfl_teams = nfl_teams
				$scope.load_season_weeks()
			)

		$scope.load_season_weeks = () ->
			console.log("(PoolEntriesCtrl.load_season_weeks) Looking up the season_weeks")
			SeasonWeeks.nested_query($scope.web_state.current_season.id).then((season_weeks) ->
				console.log("(PoolEntriesCtrl.load_season_weeks) *** Have All Season Weeks ***")
				$scope.season_weeks = season_weeks
				$scope.getWeeklyResults()
			)

		$scope.getWeeklyResults = () ->
			console.log("(PoolEntriesCtrl.getWeeklyResults) Looking up the weekly results for week_id:" + $scope.week_id)
			if AuthService.isAuthenticated() == false
				$scope.alert = { type: "danger", msg: "You are not signed in. Please Sign In to view your picks. If you think you are signed in, please sign out and try again. We are in the process of fixing this." }
				console.log("User is not authorized.")
			else
				WeekResults.nested_query($scope.week_id).then(
					(week_results) ->
						console.log("(PoolEntriesCtrl.getWeeklyResults) ...Have Week Results")
						$scope.pool_entries_still_alive = week_results[0]
						$scope.pool_entries_knocked_out_this_week = week_results[1]
						$scope.pool_entries_knocked_out_previously = week_results[2]
						$scope.unmatched_pool_entries = week_results[3]
						$scope.getSortedPicks()
					(json_error_data) ->
						console.log("(PoolEntriesCtrl.getWeeklyResults) Error getting Week Results")
						$scope.alert = { type: "danger", msg: json_error_data.data[0].error }
				)

		$scope.load_bubble_image = () ->
			console.log("(PoolEntriesCtrl.load_bubble_image) Looking up the bubble image")
			BubbleImage.nested_query($scope.web_state.current_season.id).then((url) ->
				console.log("(PoolEntriesCtrl.load_bubble_image) *** Have your bubble image for the season ***")
				console.log(url.image_percent)
				$scope.bubble_image_url = url.image_percent

				(json_error_data) ->
					console.log("(PoolEntriesCtrl.load_bubble_image) Cannot get bubble image")
					$scope.error_message = json_error_data.data[0].error
			)

		$scope.$on 'auth-login-success', ((event) ->
			console.log("(PoolEntriesCtrl) Caught auth-login-success broadcasted event!!")
			$scope.getWeeklyResults()
			$scope.alert = null
		)

		$scope.getSortedPicks = () ->
			SortedPicks.nested_query($scope.week_id).then(
				(sorted_picks) ->
					if sorted_picks.length > 7
						$scope.sorted_picks = sorted_picks.slice(7)
					else
						$scope.sorted_picks = sorted_picks
					console.log("Successfully received sorted picks")
				(json_error_data) ->
					console.log("(PoolEntriesCtrl.getSortedPicks) Cannot get sorted picks")
					$scope.error_message = json_error_data.data[0].error
			)

		$scope.still_alive_count = () ->
			if $scope.pool_entries_still_alive
				$scope.pool_entries_still_alive.length
			else
				"0"

		$scope.knocked_out_this_week_count = () ->
			if $scope.pool_entries_knocked_out_this_week
				$scope.pool_entries_knocked_out_this_week.length
			else
				"0"

		$scope.knocked_out_previously_count = () ->
			if $scope.pool_entries_knocked_out_previously
				$scope.pool_entries_knocked_out_previously.length
			else
				"0"

		$scope.getWebState()


		$scope.results_header = ->
			console.log("(matchup_header) week_id:" + parseInt($scope.week_id) + " current_week.id:" + $scope.current_week.id)
			if parseInt($scope.week_id) == $scope.current_week.id
				"Live Results (Round " + $scope.current_week.week_number + ")"
			else
				"Previous Results "
]