angular.module('AdminMatchups', ['ngResource', 'RailsApiResource', 'ui.bootstrap'])

	.factory 'FilteredMatchups', (RailsApiResource) ->
		RailsApiResource('/weeks/:parent_id/filtered_matchups')

	.controller 'AdminMatchupsCtrl', ['$scope', '$location', '$http', '$routeParams', 'Matchup', 'NflTeam', 'PoolEntry', 'currentUser', '$modal', 'WebState', 'Week', 'SeasonWeeks', 'PickResults', 'FilteredMatchups', ($scope, $location, $http, $routeParams, Matchup, NflTeam, PoolEntry, currentUser, $modal, WebState, Week, SeasonWeeks, PickResults, FilteredMatchups) ->
		console.log("AdminMatchupsCtrl")

		# Getting the current system status

		$scope.current_week = {}
		$scope.season_weeks = {}
		$scope.picks = []
		$scope.matchups_with_picks = []
		$scope.matchups_without_picks = []

		week_id = $routeParams.week_id
		$scope.week_id = week_id
		console.log("Passed Week ID:" + $scope.week_id)
		$scope.matchups = []
		$scope.pool_entries = []

		$scope.getWebState = () ->
			console.log("...Looking up the WebState")
			$scope.web_state = WebState.get(1).then((web_state) ->
				$scope.web_state = web_state
				$scope.current_week = web_state.current_week
				$scope.open_for_picks = web_state.current_week.open_for_picks
				$scope.loadPoolEntries()
			)

		$scope.getWebState()

		$scope.loadPoolEntries = () ->
			PoolEntry.query().then((pool_entries) ->
				$scope.pool_entries = pool_entries
				$scope.loadPicks()
				$scope.loadNflTeams()
				$scope.load_season_weeks()
				console.log("*** Have pool entries, picks, teams, and season-weeks ***")
			)

		$scope.load_season_weeks = () ->
			console.log("(load_season_weeks)")
			SeasonWeeks.nested_query($scope.web_state.current_week.season.id).then((season_weeks) ->
				console.log("(load_season_weeks) *** Have All Season Weeks ***")
				$scope.season_weeks = season_weeks
			)

		$scope.loadNflTeams = () ->
			NflTeam.query().then((nfl_teams) ->
				$scope.nfl_teams = nfl_teams
				console.log("*** Have nfl_teams***")
			)

		$scope.loadPicks = () ->
			console.log("in loadPicks()")
			PickResults.nested_query($scope.week_id).then(
				(picks) ->
					$scope.picks = picks
					$scope.associatePicks()
					$scope.loadMatchups()
					console.log("Have picks")
				(json_error_data) ->
					$scope.error_message = json_error_data.data[0].error
					$scope.loadMatchups()
			)

		$scope.associatePicks = ->
			for pool_entry in $scope.pool_entries
				for pick in $scope.picks
					if pick.pool_entry_id == pool_entry.id
						angular.extend(pool_entry, pick)
						console.log("A pick was associated with a pool entry")

		$scope.loadMatchups = () ->
			FilteredMatchups.nested_query($scope.week_id).then((matchups) ->
				$scope.filtered_matchups = matchups
				console.log("*** Have matchups for week:"+$scope.week_id + " ***")
			)

		# Below was used for a while, but problematic with losing certain matchups

		# $scope.isPicked = (matchup) ->
		# 	console.log("in isPicked")
		# 	for pick in $scope.picks
		# 		console.log("in scope.picks")
		# 		if pick.team_id == matchup.home_team_id
		# 			console.log("home team matches up for " + pick.nfl_team.name)
		# 			return true
		# 		else if pick.team_id == matchup.away_team_id
		# 			console.log("away team matches up for " + pick.nfl_team.name)
		# 			return true
		# 		else
		# 			console.log("no match for " + pick.nfl_team.name)
		# 			return false

		$scope.notPicked = (matchup) ->
			console.log("in notPicked")
			if $scope.picks == []
				true
			else
				for pick in $scope.picks
					if pick.team_id == (matchup.home_team_id or matchup.away_team_id)
						false 
					else 
						true

		# $scope.filterMatchups = () ->
		# 	console.log("in filterMatchups()")
		# 	for matchup in $scope.matchups
		# 		for pick in $scope.picks
		# 			if pick.team_id == (matchup.home_team_id or matchup.away_team_id)
		# 				$scope.matchups_with_picks.push matchup
		# 			else
		# 				$scope.matchups_without_picks.push matchup
		# 	console.log("end of filterMatchups")

		# Outcome Selections for Administrators

		$scope.selectTie = (matchup) ->
			console.log("Saving matchup outcome as a Tie Game")
			matchup.tie = true
			matchup.winning_team_id = null
			Matchup.save(matchup, matchup.week_id).then((matchup) ->
				$scope.matchup = matchup
				$scope.tieSelected = true
			)

		$scope.selectHomeTeamWin = (matchup) ->
			console.log("Saving matchup outcome as Home Team Wins")
			matchup.tie = false
			matchup.winning_team_id = matchup.home_team_id
			Matchup.save(matchup, matchup.week_id).then((matchup) ->
				$scope.matchup = matchup
				$scope.homeSelected = true
			)

		$scope.selectAwayTeamWin = (matchup) ->
			console.log("Saving matchup outcome as Away Team Wins")
			matchup.tie = false
			matchup.winning_team_id = matchup.away_team_id
			Matchup.save(matchup, matchup.week_id).then((matchup) ->
				$scope.matchup = matchup
			)

		$scope.cancelOutcomeSelection = (matchup) ->
			console.log("Cancelling outcome selection for matchup")
			matchup.tie = null
			matchup.winning_team_id = null
			Matchup.save(matchup, matchup.week_id)

		$scope.saveOutcome = (matchup) ->
			console.log("Saving outcome for matchup"+matchup)
			week_id = matchup.week_id
			Matchup.post("save_outcome", matchup, week_id).then(()->
				$scope.loadMatchups()
			)

		$scope.matchupCompleted = (matchup) ->
			if matchup.completed == true then true

		$scope.displayOutcomeSaveButtons = (matchup) ->
			if matchup.tie? then true

		$scope.displayMatchupEditButtons = (matchup) ->
			if matchup.tie == null then true

		$scope.tie_button_class = (matchup) ->
			if matchup.tie == true
				matchup.winning_team_text = "Tie Game"
				"btn btn-warning"
			else
				"btn btn-default"

		$scope.home_button_class = (matchup) ->
			if matchup.winning_team_id == matchup.home_team_id
				matchup.winning_team_text = matchup.home_team.name + " as the Winner"
				"btn btn-primary"
			else
				"btn btn-default"

		$scope.away_button_class = (matchup) ->
			if matchup.winning_team_id != matchup.home_team_id && matchup.tie == false
				matchup.winning_team_text = matchup.away_team.name + " as the Winner"
				"btn btn-success"
			else
				"btn btn-default"

		$scope.winningTeam = (matchup) ->
			if matchup.winning_team_id == matchup.home_team_id
				matchup.home_team.name
			else if matchup.winning_team_id == matchup.away_team_id
				matchup.away_team.name
			else
				"It was a tie!"

		$scope.deleteMatchup = (matchup) ->
			console.log("MatchupCtrl.delete...")
			week_id = matchup.week_id
			# Add checking for if there are picks associated with this Matchup
			if matchup.id?
				console.log("Deleting matchup id " + matchup.id)
				Matchup.remove(matchup, week_id).then((matchup) ->
					Matchup.nested_query($scope.week_id).then((matchups) ->
						$scope.matchups = matchups
					)
				)

		# Modal

		$scope.open = (size, matchup) ->
			modalInstance = $modal.open(
				templateUrl: "confirmOutcomeModal.html"
				controller: ModalInstanceCtrl
				size: size
				resolve:
					matchup: ->
						matchup
			)
			modalInstance.result.then ((matchup) ->
				console.log("first funciton of modalInstance result")
				$scope.saveOutcome(matchup)
			), ->
				console.log("Modal dismissed at: " + new Date())

		ModalInstanceCtrl = ($scope, $modalInstance, matchup) ->
			console.log("In ModalInstanceCtrl")
			console.log("this is what is in matchup" + matchup.id)

			$scope.matchup = matchup

			$scope.ok = ->
				$modalInstance.close(matchup)

			$scope.cancel = ->
				$modalInstance.dismiss("cancel")
	]