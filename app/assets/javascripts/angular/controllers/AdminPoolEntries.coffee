angular.module('AdminPoolEntries', ['ngResource', 'RailsApiResource', 'ui.bootstrap'])

	.controller 'AdminPoolEntriesCtrl', ['$scope', '$location', '$http', '$routeParams', 'PoolEntriesThisSeason', 'WebState', 'SeasonWeeks', 'PoolEntry', ($scope, $location, $http, $routeParams, PoolEntriesThisSeason, WebState, SeasonWeeks, PoolEntry) ->

		season_id = parseInt( $routeParams.season_id, 10 )

		$scope.getAllPoolEntries = () ->
			PoolEntriesThisSeason.nested_query(1).then((pool_entries) ->
				$scope.pool_entries = pool_entries
				console.log("(getAllPoolEntries) Have pool entries")
			)

		$scope.getAllPoolEntries()

		$scope.markPaidOrUnpaid = (pool_entry) ->
			if pool_entry.paid == (false or null)
				$scope.markAsPaid(pool_entry)
			else if pool_entry.paid == true
				$scope.markAsUnpaid(pool_entry)

		$scope.markAsPaid = (pool_entry) ->
			editing_pool_entry = pool_entry
			editing_pool_entry.paid = true
			PoolEntry.save(editing_pool_entry)

		$scope.markAsUnpaid = (pool_entry) ->
			editing_pool_entry = pool_entry
			editing_pool_entry.paid = null
			PoolEntry.save(editing_pool_entry)



		$scope.getPaidOrUnpaidButtonText = (pool_entry) ->
			if pool_entry.paid is (false or null)
				"Paid"
			else
				"Not Paid"

		$scope.getPaidOrUnpaidStatusText = (pool_entry) ->
			if pool_entry.paid is (false or null)
				"Not Paid"
			else
				"Paid"

		$scope.getPaidTextClass = (pool_entry) ->
			if pool_entry.paid is (false or null)
				"red"
			else
				"green"

	]