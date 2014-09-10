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

	.factory 'PoolEntriesAndPicks', (RailsApiResource) ->
		RailsApiResource('weeks/:parent_id/pool_entries_and_picks', 'pool_entries')

	.factory 'SeasonWeeks', (RailsApiResource) ->
		RailsApiResource('seasons/:parent_id/weeks', 'weeks')

	.controller 'MatchupsCtrl', ['$scope', '$location', '$http', '$routeParams', 'Matchup', 'NflTeam', 'PoolEntry', 'currentUser', 'Pick', '$modal', 'WebState', 'Week', 'SeasonWeeks', 'PoolEntriesAndPicks', ($scope, $location, $http, $routeParams, Matchup, NflTeam, PoolEntry, currentUser, Pick, $modal, WebState, Week, SeasonWeeks, PoolEntriesAndPicks) ->
		$scope.controller = 'MatchupsCtrl'
		console.log("MatchupsCtrl")
		console.log("$location:" + $location)
		console.log("Logged in as:" + currentUser.username)

		# Getting the current system status

		$scope.current_week = {}
		$scope.season_weeks = {}

		$scope.getWebState = () ->
			console.log("...Looking up the WebState")
			$scope.web_state = WebState.get(1).then((web_state) ->
				$scope.web_state = web_state
				$scope.current_week = web_state.current_week
				$scope.open_for_picks = web_state.current_week.open_for_picks
				$scope.loadPoolEntries()
			)

		# Routing for new matchups, or the index action for the week
		week_id = $routeParams.week_id
		$scope.week_id = week_id
		console.log("Passed Week ID:" + $scope.week_id)
		$scope.matchup_id = matchup_id = $routeParams.matchup_id
		$scope.matchups = []
		$scope.getWebState()

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

		# Gather resources and associate relevant pool entries and picks
		$scope.authorized = ->
			currentUser.authorized

		$scope.weekIsClosed = () ->
			if $scope.current_week.open_for_picks == false
				true

		$scope.load_season_weeks = () ->
			console.log("(load_season_weeks)")
			SeasonWeeks.nested_query($scope.web_state.current_week.season.id).then((season_weeks) ->
				console.log("(load_season_weeks) *** Have All Season Weeks ***")
				$scope.season_weeks = season_weeks
			)

			console.log("Getting all matchups this week")
			$scope.loadMatchups()

		# Gather resources and associate relevant pool entries and picks
		$scope.loadPoolEntries = () ->
			if currentUser.authorized == false
				$scope.alert = { type: "danger", msg: "You are not signed in. Please Sign In to view your picks. If you think you are signed in, please sign out and try again." }
				console.log("User is not authorized.")
			else
				PoolEntriesAndPicks.nested_query($scope.week_id).then(
					(pool_entries) ->
						$scope.pool_entries = pool_entries
						$scope.load_season_weeks()
						$scope.loadMatchups()
						console.log("*** Have pool entries, picks, teams, and season-weeks ***")
						$scope.alert = { type: "success", msg: "Make your picks for this week!" }
					(json_error_data) ->
						console.log("Error or unauthorized request to PoolEntriesAndPicks")
						$scope.alert = { type: "danger", msg: json_error_data.data.error }
				)

		$scope.loadMatchups = () ->
			Matchup.nested_query($scope.week_id).then((matchups) ->
				$scope.matchups = matchups
				console.log("*** Have matchups for week:"+$scope.week_id + " ***")
			)

		$scope.matchup_header = ->
			console.log("(matchup_header) week_id:" + parseInt($scope.week_id) + " current_week.id:" + $scope.current_week.id)
			if parseInt($scope.week_id) == $scope.current_week.id
				"Choose Your Pick For This Week (Week " + $scope.current_week.week_number + ")"
			else
				"Matchups for a different week"

		$scope.$on 'auth-login-success', ((event) ->
      console.log("(MatchupsCtrl) Caught auth-login-success broadcasted event!!")
      $scope.loadPoolEntries()
    )

		# $scope.getAlert = () ->
		# 	console.log("in getAlert")
		# 	if currentUser.authorized == false
		# 		$scope.alert = { type: "danger", msg: "You are not signed in. Please Sign In to view your picks." }
		# 		console.log("User is not authorized.")
		# 	else if	$scope.pool_entries.length == 0
		# 		$scope.alert = { type: "danger", msg: "All of your pool entries have been knocked out!" }
		# 		console.log("All of your pool entries have been knocked out")
		# 	else if $scope.open_for_picks == false
		# 		$scope.alert = { type: "danger", msg: "This week is closed! Your picks are locked in." }
		# 		console.log("This week is closed for addiitonal picks")
		# 	else
		# 		$scope.alert = ""
		# 		console.log("Week is open - don't show an alert")

		# User Action of Selecting a Pick

		$scope.set_editing_pool_entry = (index) ->
			$scope.editing_pool_entry = $scope.pool_entries[index]
			console.log("Set editing_pool_entry to: "+$scope.editing_pool_entry.team_name)
			console.log("This pool entry has a pick of ID " + $scope.editing_pool_entry.team_id)
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
			$scope.selectedMatchup = matchup
			$scope.selectedPick = team
			console.log("Pick selection is " + $scope.selectedPick.name)
			console.log("Value of selectedMatchup: " + $scope.selectedMatchup.home_team.name)
			$scope.hideMatchups = true

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
			console.log("MatchupsCtrl.savePick...")
			pool_entry = $scope.editing_pool_entry
			console.log("Saving pool entry " + $scope.editing_pool_entry.team_name)
			picked_matchup = matchup

			Week.post(":parent_id/create_or_update_pick", {week_id: $scope.week_id, pool_entry_id: pool_entry.id, team_id: $scope.selectedPick.id, matchup_id: picked_matchup.id}, $scope.week_id).then(
				(data) ->
					console.log("Back from savePick method")
					$scope.loadPoolEntries()
				(data) ->
					console.log("FAILED to create_or_update_pick")
				)

			$location.path ('/weeks/' + $scope.week_id + '/matchups')
			$scope.selectedMatchup = ""
			$scope.selectedPick = ""
			$scope.editing_pool_entry = null
			$scope.hideMatchups = false
			$scope.showMatchups = false
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
	]

