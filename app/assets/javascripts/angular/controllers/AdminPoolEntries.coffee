angular.module('AdminPoolEntries', ['ngResource', 'RailsApiResource', 'ui.bootstrap'])

	.controller 'AdminPoolEntriesCtrl', ['$scope', '$location', '$http', '$routeParams', 'PoolEntriesThisSeason', 'WebState', 'SeasonWeeks', ($scope, $location, $http, $routeParams, PoolEntriesThisSeason, WebState, SeasonWeeks) ->

		season_id = parseInt( $routeParams.season_id, 10 )

		$scope.getAllPoolEntries = () ->
			PoolEntriesThisSeason.nested_query(1).then((pool_entries) ->
				$scope.pool_entries = pool_entries
				console.log("(getAllPoolEntries) Have pool entries")
			)

		$scope.getAllPoolEntries()

	]