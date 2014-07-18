angular.module('PoolEntries', ['ngResource', 'RailsApiResource'])

	.factory 'PoolEntriesThisWeek', (RailsApiResource) ->
		RailsApiResource('weeks/:parent_id/week_results', 'pool_entries')

	.factory 'NflTeam', (RailsApiResource) ->
		RailsApiResource('nfl_teams', 'nfl_teams')

	.factory 'Pick', (RailsApiResource) ->
		RailsApiResource('weeks/:parent_id/week_picks', 'picks')

	.controller 'PoolEntriesCtrl', ['$scope', '$location', '$http', '$routeParams', 'NflTeam', 'PoolEntriesThisWeek', 'Pick', ($scope, $location, $http, $routeParams, NflTeam, PoolEntriesThisWeek, Pick) ->

		week_id = $routeParams.week_id

		NflTeam.query().then((nfl_teams) ->
			$scope.nfl_teams = nfl_teams
			console.log("*** Have nfl_teams***")
		)

		PoolEntriesThisWeek.nested_query(week_id).then((pool_entries) ->
			$scope.pool_entries_knocked_out_this_week = pool_entries[0]
			$scope.pool_entries_still_alive = pool_entries[1]
			$scope.gatherPicks()
			console.log("*** Have pool entries for results ***")
		)

		$scope.gatherPicks = ->
			$scope.picks = []
			Pick.nested_query(week_id).then((this_weeks_picks) ->
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

	]