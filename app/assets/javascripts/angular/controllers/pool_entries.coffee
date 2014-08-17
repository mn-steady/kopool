angular.module('PoolEntries', ['ngResource', 'RailsApiResource'])

	.factory 'WeekResults', (RailsApiResource) ->
		RailsApiResource('weeks/:parent_id/week_results', 'pool_entries')

	.factory 'NflTeam', (RailsApiResource) ->
		RailsApiResource('nfl_teams', 'nfl_teams')

	.factory 'PickResults', (RailsApiResource) ->
		RailsApiResource('weeks/:parent_id/week_picks', 'picks')

	.controller 'PoolEntriesCtrl', ['$scope', '$location', '$http', '$routeParams', 'NflTeam', 'WeekResults', 'PickResults', 'WebState', 'SeasonWeeks', ($scope, $location, $http, $routeParams, NflTeam, WeekResults, PickResults, WebState, SeasonWeeks) ->

		week_id = parseInt( $routeParams.week_id, 10 )
		$scope.week_id = week_id
		console.log("The passed-in week's ID is: " + $scope.week_id)

		$scope.getResultsResources = () ->

			$scope.current_week = {}
			$scope.season_weeks = {}

			console.log("...Looking up the WebState")
			$scope.web_state = WebState.get(1).then((web_state) ->
				$scope.web_state = web_state
				$scope.current_week = web_state.current_week
				$scope.open_for_picks = web_state.current_week.open_for_picks
				$scope.load_season_weeks()
			)

			NflTeam.query().then((nfl_teams) ->
				$scope.nfl_teams = nfl_teams
				console.log("*** Have nfl_teams***")
			)

			WeekResults.nested_query(week_id).then(
				(week_results) ->
					$scope.pool_entries_still_alive = week_results[0]
					$scope.pool_entries_knocked_out_this_week = week_results[1]
					$scope.pool_entries_knocked_out_previously = week_results[2]
					$scope.unmatched_pool_entries = week_results[3]
					console.log("*** Have week results ***")
					$scope.gatherPicks()
				(json_error_data) ->
					$scope.error_message = json_error_data.data[0].error
			)

		$scope.getResultsResources()

		$scope.load_season_weeks = () ->
			console.log("(load_season_weeks)")
			SeasonWeeks.nested_query($scope.web_state.current_week.season.id).then((season_weeks) ->
				console.log("(load_season_weeks) *** Have All Season Weeks ***")
				$scope.season_weeks = season_weeks
			)

		$scope.sortPoolEntries = (pool_entries) ->
			$scope.pool_entries_knocked_out_this_week = []
			$scope.pool_entries_still_alive = []
			$scope.pool_entries_knocked_out_previously = []
			$scope.pool_entries_not_yet_paid = [] # Still need to support this below

			console.log("sorting pool entries")

			for pool_entry in pool_entries
				if pool_entry.knocked_out == false
					$scope.pool_entries_still_alive.push pool_entry
				else if pool_entry.knocked_out_week_id == week_id
					$scope.pool_entries_knocked_out_this_week.push pool_entry
				else if pool_entry.knocked_out == true
					$scope.pool_entries_knocked_out_previously.push pool_entry

			$scope.gatherPicks()


		$scope.gatherPicks = () ->
			$scope.picks = []
			PickResults.nested_query(week_id).then((this_weeks_picks) ->
				$scope.picks = this_weeks_picks
				console.log("gathered Picks")
				$scope.associatePicks()
			)

		$scope.associatePicks = () ->
			console.log("in associatePicks")
			for pool_entry in $scope.pool_entries_knocked_out_this_week
				console.log("Looking at pool entry of ID " + pool_entry.id + " in knocked_out_this_week")
				for pick in $scope.picks
					if pick.pool_entry_id == pool_entry.id
						console.log("KNOCKED OUT: A pick with pool entry ID of " + pick.pool_entry_id + " was associated with a pool entry of ID: " + pool_entry.id )
						angular.extend(pool_entry, pick)
			console.log("Finished knocked out")
			
			for pool_entry in $scope.pool_entries_still_alive
				console.log("Looking at pool entry of ID " + pool_entry.id + " in still_alive")
				for pick in $scope.picks
					if pick.pool_entry_id == pool_entry.id
						console.log("STILL ALIVE: A pick with pool entry ID of " + pick.pool_entry_id + " was associated with a pool entry of ID: " + pool_entry.id )
						angular.extend(pool_entry, pick)
			console.log("Finished still alive")

		$scope.results_header = ->
			console.log("(matchup_header) week_id:" + parseInt($scope.week_id) + " current_week.id:" + $scope.current_week.id)
			if parseInt($scope.week_id) == $scope.current_week.id
				"Live Results from This Round (Week " + $scope.current_week.week_number + ")"
			else
				"Results From a Previous Week"

	]