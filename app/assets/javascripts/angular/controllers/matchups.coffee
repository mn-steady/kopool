angular.module('Matchups', ['ngResource', 'RailsApiResource', 'ui.bootstrap'])

	.factory 'Matchup', (RailsApiResource) ->
		RailsApiResource('weeks/:parent_id/matchups', 'matchups')

	.factory 'NflTeam', (RailsApiResource) ->
		RailsApiResource('nfl_teams', 'nfl_teams')

	.factory 'PoolEntry', (RailsApiResource) ->
		RailsApiResource('pool_entries', 'pool_entries')

	.factory 'Pick', (RailsApiResource) ->
		RailsApiResource('weeks/:parent_id/picks', 'picks')

	.controller 'MatchupsCtrl', ['$scope', '$location', '$http', '$routeParams', 'Matchup', 'NflTeam', 'PoolEntry', 'currentUser', 'Pick', ($scope, $location, $http, $routeParams, Matchup, NflTeam, PoolEntry, currentUser, Pick) ->
		$scope.controller = 'MatchupsCtrl'
		console.log("MatchupsCtrl")
		console.log("$location:" + $location)
		console.log("Logged in as:" + currentUser.username)

		# Routing for new matchups, or the index action for the week

		$scope.week_id = week_id = $routeParams.week_id
		$scope.matchup_id = matchup_id = $routeParams.matchup_id

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
			Matchup.nested_query(week_id).then((matchups) ->
				$scope.matchups = matchups
				console.log("*** Have matchups***")
			)

		# Gather resources and associate relevant pool entries and picks

		$scope.matchups = []
		NflTeam.query().then((nfl_teams) ->
			$scope.nfl_teams = nfl_teams
			console.log("*** Have nfl_teams***")
		)

		$scope.pool_entries = []
		PoolEntry.query().then((pool_entries) ->
			$scope.pool_entries = pool_entries
			$scope.gatherPicks()
			console.log("*** Have pool entries ***")
		)

		$scope.gatherPicks = ->
			$scope.picks = []
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
				$scope.awaySelected = true
			)

		$scope.saveWeekOutcomes = (matchups) ->
			console.log("Saving all outcomes for the week...")
			week_id = matchups[0].week_id
			Matchup.save_collection(week_id, week_id)
			$location.path('/weeks/#{week_id}/matchups')

		# Next 4 lines of code not used yet. Trying to highlight a specific button

		$scope.tieSelected = tie_selected = false
		$scope.homeSelected = home_selected = false
		$scope.awaySelected = away_selected = false

		$scope.outcomeCollection = [tie_selected, home_selected, away_selected]

		$scope.outcome_button_class = (matchup) ->
			if matchup.tie == true
				"btn btn-warning"
			else if matchup.winning_team_id == matchup.home_team_id
				"btn btn-primary"
			else if matchup.winning_team_id != matchup.home_team_id
				"btn btn-success"
			else
				"btn btn-default"

		# User Action of Selecting a Pick

		$scope.set_editing_pool_entry = (index) ->
			$scope.editing_pool_entry = index + 1
			console.log("Set editing_pool_entry to: "+$scope.editing_pool_entry)
			$scope.showMatchups = true

		$scope.pool_entry_button_class = (index) ->
			if index + 1 == $scope.editing_pool_entry
				"btn btn-primary"
			else
				"btn btn-default"

		$scope.selectedMatchup = ""

		$scope.selectedPick = ""

		$scope.handleTeamSelection = (matchup, team) ->
			$scope.selectMatchup(matchup, team)
			$scope.selectedPick = team
			console.log("Pick selection is " + $scope.selectedPick.name)
			# I want to select an individual team here too (for UI and savePick function)

		$scope.selectMatchup = (matchup, team) ->
			$scope.selectedMatchup = matchup

		$scope.isSelectedMatchup = (matchup) ->
			$scope.selectedMatchup == matchup

		$scope.getPickedTeamName = (pool_entry) ->
			if pool_entry.nfl_team
				pool_entry.nfl_team.name
			else
				"Choose a Winning Team Below!"


		# Saving and Creation Actions

		$scope.savePick = (matchup, editing_pool_entry) ->
			# Talk to Rails and create a new pick when the Save Pick button is clicked
			# Will need to know which team they are choosing
			console.log("MatchupsCtrl.savePick...")
			pool_entry = $scope.pool_entries[editing_pool_entry - 1]
			week_id = matchup.week_id

			console.log("Sending Pick info to Rails...")
			if pool_entry.team_id
				console.log("Sending UPDATE pick to rails")
				existing_pick = (pick for pick in $scope.picks when pick.pool_entry_id is pool_entry.id)[0]
				console.log("Found existing_pick")
				existing_pick.pool_entry_id = pool_entry.id
				existing_pick.week_id = week_id
				existing_pick.team_id = $scope.selectedPick.id
				console.log("Updated existing_pick")
				Pick.save(existing_pick, week_id)

			else
				$scope.new_pick = {pool_entry_id: pool_entry.id, week_id: week_id, team_id: $scope.selectedPick.id}
				console.log("Sending CREATE pick to rails")
				Pick.create($scope.new_pick, week_id)

			$location.path ('/weeks/' + $scope.week_id + '/matchups')

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

		# Datepicker

		$scope.today = ->
			$scope.dt = new Date()
			return

		$scope.today()
		$scope.clear = ->
			$scope.dt = null
			return

		$scope.open = ($event) ->
			$event.preventDefault()
			$event.stopPropagation()
			$scope.opened = true
			return

		$scope.dateOptions =
			formatYear: "yy"
			startingDay: 1

		$scope.initDate = new Date("2016-15-20")
		$scope.formats = [
			"dd-MMMM-yyyy"
			"yyyy/MM/dd"
			"dd.MM.yyyy"
			"shortDate"
		]
		$scope.format = $scope.formats[0]
		return
	]