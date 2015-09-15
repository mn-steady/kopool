@kopool.filter('matchupDisplay', () ->
	(matchup) ->
		console.log matchup
		"#{matchup.away_team.name} at #{matchup.home_team.name}"
)