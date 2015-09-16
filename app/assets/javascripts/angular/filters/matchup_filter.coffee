@kopool.filter('matchupDisplay', () ->
	(matchup) ->
		"#{matchup.away_team.name} at #{matchup.home_team.name}: Locked = #{!!matchup.locked}"
)