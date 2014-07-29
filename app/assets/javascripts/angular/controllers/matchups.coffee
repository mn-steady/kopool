angular.module('Matchups', ['ngResource', 'RailsApiResource', 'ui.bootstrap'])

	.factory 'Matchup', (RailsApiResource) ->
		RailsApiResource('weeks/:parent_id/matchups', 'matchups')

	.factory 'NflTeam', (RailsApiResource) ->
		RailsApiResource('nfl_teams', 'nfl_teams')

	.factory 'PoolEntry', (RailsApiResource) ->
		RailsApiResource('pool_entries', 'pool_entries')

	.factory 'Pick', (RailsApiResource) ->
		RailsApiResource('weeks/:parent_id/picks', 'picks')

	.factory 'WebState', (RailsApiResource) ->
			RailsApiResource('admin/web_states', 'webstate')

	.factory 'Week', (RailsApiResource) ->
      RailsApiResource('weeks', 'weeks')

	.controller 'MatchupsCtrl', ['$scope', '$location', '$http', '$routeParams', 'Matchup', 'NflTeam', 'PoolEntry', 'currentUser', 'Pick', '$modal', 'WebState', 'Week', ($scope, $location, $http, $routeParams, Matchup, NflTeam, PoolEntry, currentUser, Pick, $modal, WebState, Week) ->
		$scope.controller = 'MatchupsCtrl'
		console.log("MatchupsCtrl")
		console.log("$location:" + $location)
		console.log("Logged in as:" + currentUser.username)

		# Getting the current system status

		$scope.week = {}

		console.log("...Looking up the WebState")
		$scope.web_state = WebState.get(1).then((web_state) ->
			$scope.web_state = web_state
			$scope.week = web_state.current_week
			$scope.open_for_picks = web_state.current_week.open_for_picks
			$scope.loadPoolEntries().then(() ->
				$scope.getAlert()
			)
		)

		$scope.loadMatchups = () ->
			Matchup.nested_query($scope.week_id).then((matchups) ->
				$scope.matchups = matchups
				console.log("*** Have matchups for week:"+$scope.week_id + " ***")
			)

		$scope.authorized = ->
      currentUser.authorized

		$scope.weekIsClosed = () ->
			if $scope.week.open_for_picks == false
				true

		# Routing for new matchups, or the index action for the week

		week_id = $routeParams.week_id
		$scope.week_id = week_id
		console.log("Handling Week ID:" + $scope.week_id)
		$scope.matchup_id = matchup_id = $routeParams.matchup_id
		$scope.matchups = []
		$scope.pool_entries = []

		if matchup_id? and matchup_id == "new"
			console.log("...Creating a new matchup")
			$scope.matchup = new Matchup({})
			$scope.matchup.week_id = $scope.week_id
		else if matchup_id?
			console.log("...Looking up a single matchup")
			$scope.matchup = Matchup.get(matchup_id, week_id).then((matchup) ->
				$scope.matchup = matchup
				console.log("Returned matchup" + matchup)
			)
		else
			console.log("Getting all matchups this week")
			$scope.loadMatchups()

		# Gather resources and associate relevant pool entries and picks
		
		$scope.loadPoolEntries = () ->
			PoolEntry.query().then((pool_entries) ->
				$scope.pool_entries = pool_entries
				$scope.gatherPicks()
				$scope.loadNflTeams()
				console.log("*** Have pool entries ***")
			)

		$scope.loadNflTeams = () ->
			NflTeam.query().then((nfl_teams) ->
				$scope.nfl_teams = nfl_teams
				console.log("*** Have nfl_teams***")
			)

		$scope.gatherPicks = ->
			$scope.picks = []
			console.log("in gatherPicks()")
			Pick.nested_query(week_id).then((picks) ->
				$scope.picks = picks
				$scope.associatePicks()
			)

		$scope.associatePicks = ->
			for pool_entry in $scope.pool_entries
				for pick in $scope.picks
					if pick.pool_entry_id == pool_entry.id
						angular.extend(pool_entry, pick)
						console.log("A pick was associated with a pool entry")

		$scope.getAlert = () ->
			console.log("in getAlert")
			if $scope.pool_entries.length == 0
				$scope.alert = { type: "danger", msg: "All of your pool entries have been knocked out!" }
				console.log("All of your pool entries have been knocked out")
			else if $scope.open_for_picks == false
				$scope.alert = { type: "danger", msg: "This week is closed! Your picks are locked in." }
				console.log("This week is closed for addiitonal picks")
			else
				$scope.alert = ""
				console.log("Week is open - don't show an alert")

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

		# User Action of Selecting a Pick

		$scope.set_editing_pool_entry = (index) ->
			$scope.editing_pool_entry = $scope.pool_entries[index]
			console.log("Set editing_pool_entry to: "+$scope.editing_pool_entry)
			$scope.showMatchups = true

		$scope.pool_entry_button_class = (pool_entry) ->
			if pool_entry == $scope.editing_pool_entry
				"btn btn-primary"
			else
				"btn btn-default"


		# Controls which pool entry shows up at the top of the screen
		$scope.notSelectedPoolEntry = (pool_entry) ->
			if $scope.editing_pool_entry == null
				false
			else if $scope.editing_pool_entry == pool_entry
				false
			else
				true
			

		$scope.selectedMatchup = ""

		$scope.selectedPick = ""

		$scope.editing_pool_entry = null

		$scope.handleTeamSelection = (matchup, team) ->
			$scope.selectMatchup(matchup, team)
			$scope.selectedPick = team
			console.log("Pick selection is " + $scope.selectedPick.name)
			console.log("Value of selectedMatchup: " + $scope.selectedMatchup.home_team.name)
			$scope.hideMatchups = true
			# I want to select an individual team here too (for UI and savePick function)

		$scope.selectMatchup = (matchup, team) ->
			$scope.selectedMatchup = matchup

		$scope.isSelectedMatchup = (matchup) ->
			$scope.selectedMatchup == matchup

		$scope.isSelectedTeam = (team) ->
			$scope.selectedPick == team

		$scope.cancelTeamSelection = ->
			$scope.selectedMatchup = ""
			$scope.selectedPick = ""
			$scope.hideMatchups = false

		$scope.getPickedTeamName = (pool_entry) ->
			console.log("getting pool entry name in getPickedTeamName")
			if pool_entry.nfl_team
				pool_entry.nfl_team.name
			else
				"Choose a Winning Team Below!"


		# Saving and Creation Actions

		$scope.savePick = (matchup, editing_pool_entry) ->
			# Talk to Rails and create a new pick when the Save Pick button is clicked
			# Will need to know which team they are choosing
			console.log("MatchupsCtrl.savePick...")
			pool_entry = $scope.editing_pool_entry
			week_id = matchup.week_id
			picked_matchup = matchup

			console.log("Sending Pick info to Rails...")
			if pool_entry.team_id
				console.log("Sending UPDATE pick to rails")
				for pick in $scope.picks
					if pick.pool_entry_id = pool_entry.pool_entry_id 
						existing_pick = pick
				console.log("Found existing_pick")
				existing_pick.pool_entry_id = pool_entry.pool_entry_id
				existing_pick.week_id = week_id
				existing_pick.team_id = $scope.selectedPick.id
				existing_pick.matchup_id = picked_matchup.id
				console.log("Updated existing_pick")
				Pick.save(existing_pick, week_id).then((existing_pick) ->
					$scope.selectedMatchup = ""
					$scope.selectedPick = ""
					$scope.hideMatchups = false
					console.log("existing_pick: " + existing_pick)
				)

			else
				$scope.new_pick = {pool_entry_id: pool_entry.id, week_id: week_id, team_id: $scope.selectedPick.id, matchup_id: picked_matchup.id}
				console.log("Sending CREATE pick to rails")
				Pick.create($scope.new_pick, week_id)

			$location.path ('/weeks/' + $scope.week_id + '/matchups')
			$scope.editing_pool_entry = null
			$scope.showMatchups = false
			$scope.loadPoolEntries()
			$scope.alert = { type: "success", msg: "Your pick was saved! Good luck!" }
			console.log("End of savePick method")

		$scope.save = (matchup) ->
			console.log("MatchupsCtrl.save...")
			week_id = matchup.week_id
			if matchup.id?
				console.log("Saving matchup id " + matchup.id)
				matchup.home_team_id = $scope.selected_home_team.id
				matchup.away_team_id = $scope.selected_away_team.id
				matchup.game_time = $scope.selected_game_time
				Matchup.save(matchup, $scope.week_id).then((matchup) ->
					$scope.matchup = matchup
				)
			else
				console.log("First-time save need POST new id")
				matchup.home_team_id = $scope.selected_home_team.id
				matchup.away_team_id = $scope.selected_away_team.id
				matchup.game_time = $scope.selected_game_time
				Matchup.create(matchup, $scope.week_id).then((matchup) ->
					$scope.matchup = matchup
				)
			$location.path ('/weeks/' + $scope.week_id + '/matchups/admin')

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

		