angular.module('PoolEntries', ['ngResource', 'RailsApiResource'])

	.factory 'PoolEntriesThisWeek', (RailsApiResource) ->
		RailsApiResource('weeks/:parent_id/week_results', 'pool_entries')

	.factory 'NflTeam', (RailsApiResource) ->
		RailsApiResource('nfl_teams', 'nfl_teams')

	.factory 'PickResults', (RailsApiResource) ->
		RailsApiResource('weeks/:parent_id/week_picks', 'picks')

	.controller 'PoolEntriesCtrl', ['$scope', '$location', '$http', '$routeParams', 'NflTeam', 'PoolEntriesThisWeek', 'PickResults', ($scope, $location, $http, $routeParams, NflTeam, PoolEntriesThisWeek, PickResults) ->

		week_id = parseInt( $routeParams.week_id, 10 )
		$scope.week_id = week_id
		console.log("This week's ID is: " + $scope.week_id)

		$scope.getResultsResources = () ->

			NflTeam.query().then((nfl_teams) ->
				$scope.nfl_teams = nfl_teams
				console.log("*** Have nfl_teams***")
			)

			PoolEntriesThisWeek.nested_query(week_id).then(
				(pool_entries) ->
					$scope.pool_entries = pool_entries
					$scope.sortPoolEntries(pool_entries)
					console.log("*** Have pool entries for results ***")
				(json_error_data) ->
					$scope.error_message = json_error_data.data[0].error
			)

		$scope.getResultsResources()

		$scope.sortPoolEntries = (pool_entries) ->
			$scope.pool_entries_knocked_out_this_week = []
			$scope.pool_entries_still_alive = []
			$scope.pool_entries_knocked_out_previously = []
			$scope.pool_entries_not_yet_paid = []

			console.log("sorting pool entries")

			for pool_entry in pool_entries
				if pool_entry.knocked_out == false
					$scope.pool_entries_still_alive.push pool_entry
				else if pool_entry.knocked_out_week_id == week_id
					$scope.pool_entries_knocked_out_this_week.push pool_entry
				else if pool_entry.knocked_out == true
					$scope.pool_entries_knocked_out_previously.push pool_entry

			$scope.gatherPicks()


		$scope.gatherPicks = ->
			$scope.picks = []
			PickResults.nested_query(week_id).then((this_weeks_picks) ->
				$scope.picks = this_weeks_picks
				$scope.associatePicks()
			)

		$scope.associatePicks = ->
			console.log("in associatePicks")
			for pool_entry in $scope.pool_entries_knocked_out_this_week
				for pick in $scope.picks
					if pick.pool_entry_id == pool_entry.id
						angular.extend(pool_entry, pick)
						console.log("A pick was associated with a pool entry that has been knocked out")
			for pool_entry in $scope.pool_entries_still_alive
				for pick in $scope.picks
					if pick.pool_entry_id == pool_entry.id
						angular.extend(pool_entry, pick)
						console.log("A pick was associated with a pool entry that is still alive")

		# Filter Functions for the Results Page

	]