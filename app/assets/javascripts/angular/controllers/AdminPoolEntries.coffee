angular.module('AdminPoolEntries', ['ngResource', 'RailsApiResource', 'ui.bootstrap'])

	.factory 'UnpickedPoolEntries', (RailsApiResource) ->
		RailsApiResource('weeks/:parent_id/unpicked', 'unpicked_pool_entries')

	.factory 'PoolEntriesThisSeason', (RailsApiResource) ->
    RailsApiResource('seasons/:parent_id/season_results', 'pool_entries')

	.controller 'AdminPoolEntriesCtrl', ['$scope', '$location', '$http', '$routeParams', 'PoolEntriesThisSeason', 'WebState', 'SeasonWeeks', 'PoolEntry', 'UnpickedPoolEntries', '$modal', ($scope, $location, $http, $routeParams, PoolEntriesThisSeason, WebState, SeasonWeeks, PoolEntry, UnpickedPoolEntries, $modal) ->

		season_id = parseInt( $routeParams.season_id, 10 )
		$scope.pool_entries = []
		$scope.unpicked_pool_entries = []

		$scope.getAllPoolEntries = () ->
			PoolEntriesThisSeason.nested_query($scope.web_state.current_season.id).then((pool_entries) ->
				$scope.pool_entries = pool_entries
				console.log("(getAllPoolEntries) Have pool entries")
			)

		$scope.getWebState = () ->
			console.log("...Looking up the WebState")
			$scope.web_state = WebState.get(1).then((web_state) ->
				$scope.web_state = web_state
				$scope.current_week = web_state.current_week
				$scope.open_for_picks = web_state.current_week.open_for_picks
				$scope.getUnpickedPoolEntries()
				$scope.getAllPoolEntries()
			)

		$scope.getWebState()

		$scope.getUnpickedPoolEntries = () ->
			UnpickedPoolEntries.nested_query($scope.current_week.id).then((unpicked_pool_entries) ->
				console.log("in getUnpickedPoolEntries")
				$scope.unpicked_pool_entries = unpicked_pool_entries
			)

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

		$scope.open = (size, pool_entry) ->
			modalInstance = $modal.open(
				templateUrl: "confirmPaymentModal.html"
				controller: ModalInstanceCtrl
				size: size
				resolve:
					pool_entry: ->
						pool_entry
			)
			modalInstance.result.then ((pool_entry) ->
				$scope.markPaidOrUnpaid(pool_entry)
			), ->
				console.log("Modal dismissed at: " + new Date())

		ModalInstanceCtrl = ($scope, $modalInstance, pool_entry) ->
			$scope.pool_entry = pool_entry

			$scope.ok = ->
				$modalInstance.close(pool_entry)

			$scope.cancel = ->
				$modalInstance.dismiss("cancel")

	]