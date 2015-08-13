# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

			user1 = User.create!(email: "user1@example.com", password: "password", password_confirmation: "password", phone: "1234567890", name: "User 1")
			user2 = User.create!(email: "user2@example.com", password: "password", password_confirmation: "password", phone: "2234567890", name: "User 2")
			user3 = User.create!(email: "user3@example.com", password: "password", password_confirmation: "password", phone: "3234567890", name: "User 3")
			user4 = User.create!(email: "user4@example.com", password: "password", password_confirmation: "password", phone: "4234567890", name: "User 4")
			admin = User.create!(email: "admin@example.com", password: "password", password_confirmation: "password", phone: "1234567890", name: "Administrator", admin: true)

			season = Season.create!(year: 2015, name: "2015 Season", entry_fee: 50)
			season2 = Season.create!(year: 2016, name: "2016 Season", entry_fee: 50)
			week1 = Week.create!(season: season, week_number: 1, start_date: DateTime.new(2015, 8, 5), deadline: DateTime.new(2015, 8, 8), end_date: DateTime.new(2015, 8, 11))
			week2 = Week.create!(season: season, week_number: 2, start_date: DateTime.new(2015, 8, 12), deadline: DateTime.new(2015, 8, 15), end_date: DateTime.new(2015, 8, 18))
			week3 = Week.create!(season: season, week_number: 3, start_date: DateTime.new(2015, 8, 19), deadline: DateTime.new(2015, 8, 22), end_date: DateTime.new(2015, 8, 25))
			week4 = Week.create!(season: season, week_number: 4, start_date: DateTime.new(2015, 8, 26), deadline: DateTime.new(2015, 8, 29), end_date: DateTime.new(2015, 9, 1))
			
			web_state = WebState.create(week_id: week4.id, season_id: season.id)

			pool_entry1 = PoolEntry.create!(user: user1, team_name: "User 1 Team One", paid: true, season_id: season.id)
			pool_entry2 = PoolEntry.create!(user: user1, team_name: "User 1 Team Two", paid: true, season_id: season.id)
			pool_entry3 = PoolEntry.create!(user: user1, team_name: "User 1 Team Three", paid: true, season_id: season.id)
			pool_entry4 = PoolEntry.create!(user: user2, team_name: "User 2 Team One", paid: true, season_id: season.id)
			pool_entry5 = PoolEntry.create!(user: user2, team_name: "User 2 Team Two", paid: true, season_id: season.id)
			pool_entry6 = PoolEntry.create!(user: user2, team_name: "User 2 Team Three", paid: true, season_id: season.id)
			pool_entry7 = PoolEntry.create!(user: user3, team_name: "User 3 Team One", paid: true, season_id: season.id)
			pool_entry8 = PoolEntry.create!(user: user3, team_name: "User 3 Team Two", paid: true, season_id: season.id)
			pool_entry9 = PoolEntry.create!(user: user3, team_name: "User 3 Team Three", paid: true, season_id: season.id)
			pool_entry10 = PoolEntry.create!(user: user4, team_name: "User 4 Team One", paid: true, season_id: season.id)
			pool_entry11 = PoolEntry.create!(user: user4, team_name: "User 4 Team Two", paid: true, season_id: season.id)
			pool_entry12 = PoolEntry.create!(user: user4, team_name: "User 4 Team Three", paid: true, season_id: season.id)

			broncos = NflTeam.create(name: "Denver Broncos", conference: "NFC", division: "West")
			vikings = NflTeam.create(name: "Minnesota Vikings", conference: "NFC", division: "North")
			packers = NflTeam.create(name: "Green Bay Packers", conference: "NFC", division: "North")
			lions = NflTeam.create(name: "Detroit Lions", conference: "NFC", division: "North")
			chargers = NflTeam.create(name: "San Diego Chargers", conference: "AFC", division: "West")
			steelers = NflTeam.create(name: "Pittsburg Steelers", conference: "AFC", division: "East")

			matchup1_1 = Matchup.create!(week_id: week1.id, home_team: broncos, away_team: vikings, game_time: DateTime.new(2015,8,10,11))
			matchup1_2 = Matchup.create!(week_id: week1.id, home_team: packers, away_team: lions, game_time: DateTime.new(2015,8,10,11))
			matchup1_3 = Matchup.create!(week_id: week1.id, home_team: chargers, away_team: steelers, game_time: DateTime.new(2015,8,10,11))
			matchup2_1 = Matchup.create!(week_id: week2.id, home_team: broncos, away_team: vikings, game_time: DateTime.new(2015,8,17,11))
			matchup2_2 = Matchup.create!(week_id: week2.id, home_team: packers, away_team: lions, game_time: DateTime.new(2015,8,17,11))
			matchup2_3 = Matchup.create!(week_id: week2.id, home_team: chargers, away_team: steelers, game_time: DateTime.new(2015,8,17,11))
			matchup3_1 = Matchup.create!(week_id: week3.id, home_team: broncos, away_team: vikings, game_time: DateTime.new(2015,8,24,11))
			matchup3_2 = Matchup.create!(week_id: week3.id, home_team: packers, away_team: lions, game_time: DateTime.new(2015,8,24,11))
			matchup3_3 = Matchup.create!(week_id: week3.id, home_team: chargers, away_team: steelers, game_time: DateTime.new(2015,8,24,11))
			matchup4_1 = Matchup.create!(week_id: week4.id, home_team: broncos, away_team: vikings, game_time: DateTime.new(2015,8,31,11))
			matchup4_2 = Matchup.create!(week_id: week4.id, home_team: packers, away_team: lions, game_time: DateTime.new(2015,8,31,11))
			matchup4_3 = Matchup.create!(week_id: week4.id, home_team: chargers, away_team: steelers, game_time: DateTime.new(2015,8,31,11))

			# Week 1 winners: Broncos, Packers, Chargers
			# Week 2 winners: Vikings, Lions, Steelers
			# Week 3 winners: Broncos, Packers, Chargers
			# Week 4 winners: Vikings, Lions, Steelers

			# User 1 will lose 1 entry each in weeks 1, 2, and 3
			# User 2 will lose 2 entries in week 1 and the third in week 2
			# User 3 will lose 1 entry each in weeks 2 and 3, with 1 remaining
			# User 4 will lose 1 entry in week 4, with 2 remaining

			pick1_1 = Pick.create!(pool_entry_id: pool_entry1.id, week_id: week1.id, team_id: vikings.id, matchup_id: matchup1_1.id)
			pick1_2 = Pick.create!(pool_entry_id: pool_entry2.id, week_id: week1.id, team_id: packers.id, matchup_id: matchup1_2.id)
			pick1_3 = Pick.create!(pool_entry_id: pool_entry3.id, week_id: week1.id, team_id: chargers.id, matchup_id: matchup1_3.id)
			pick1_4 = Pick.create!(pool_entry_id: pool_entry4.id, week_id: week1.id, team_id: vikings.id, matchup_id: matchup1_1.id)
			pick1_5 = Pick.create!(pool_entry_id: pool_entry5.id, week_id: week1.id, team_id: lions.id, matchup_id: matchup1_2.id)
			pick1_6 = Pick.create!(pool_entry_id: pool_entry6.id, week_id: week1.id, team_id: chargers.id, matchup_id: matchup1_3.id)
			pick1_7 = Pick.create!(pool_entry_id: pool_entry7.id, week_id: week1.id, team_id: broncos.id, matchup_id: matchup1_1.id)
			pick1_8 = Pick.create!(pool_entry_id: pool_entry8.id, week_id: week1.id, team_id: packers.id, matchup_id: matchup1_2.id)
			pick1_9 = Pick.create!(pool_entry_id: pool_entry9.id, week_id: week1.id, team_id: chargers.id, matchup_id: matchup1_3.id)
			pick1_10 = Pick.create!(pool_entry_id: pool_entry10.id, week_id: week1.id, team_id: broncos.id, matchup_id: matchup1_1.id)
			pick1_11 = Pick.create!(pool_entry_id: pool_entry11.id, week_id: week1.id, team_id: packers.id, matchup_id: matchup1_2.id)
			pick1_12 = Pick.create!(pool_entry_id: pool_entry12.id, week_id: week1.id, team_id: chargers.id, matchup_id: matchup1_3.id)

			# Handle Week 1 Outcomes

			matchup1_1.update_attributes(winning_team_id: broncos.id)
			matchup1_2.update_attributes(winning_team_id: packers.id)
			matchup1_3.update_attributes(winning_team_id: chargers.id)
			Matchup.handle_matchup_outcome!(matchup1_1.id)
			Matchup.handle_matchup_outcome!(matchup1_2.id)
			Matchup.handle_matchup_outcome!(matchup1_3.id)

			# Week 2 Picks

			pick2_2 = Pick.create(pool_entry_id: pool_entry2.id, week_id: week2.id, team_id: packers.id, matchup_id: matchup2_2.id)
			pick2_3 = Pick.create(pool_entry_id: pool_entry3.id, week_id: week2.id, team_id: steelers.id, matchup_id: matchup2_3.id)
			pick2_6 = Pick.create(pool_entry_id: pool_entry6.id, week_id: week2.id, team_id: chargers.id, matchup_id: matchup2_3.id)
			pick2_7 = Pick.create(pool_entry_id: pool_entry7.id, week_id: week2.id, team_id: broncos.id, matchup_id: matchup2_1.id)
			pick2_8 = Pick.create(pool_entry_id: pool_entry8.id, week_id: week2.id, team_id: lions.id, matchup_id: matchup2_2.id)
			pick2_9 = Pick.create(pool_entry_id: pool_entry9.id, week_id: week2.id, team_id: steelers.id, matchup_id: matchup2_3.id)
			pick2_10 = Pick.create(pool_entry_id: pool_entry10.id, week_id: week2.id, team_id: vikings.id, matchup_id: matchup2_1.id)
			pick2_11 = Pick.create(pool_entry_id: pool_entry11.id, week_id: week2.id, team_id: lions.id, matchup_id: matchup2_2.id)
			pick2_12 = Pick.create(pool_entry_id: pool_entry12.id, week_id: week2.id, team_id: steelers.id, matchup_id: matchup2_3.id)

			# Handle Week 2 Outcomes

			matchup2_1.update_attributes(winning_team_id: vikings.id)
			matchup2_2.update_attributes(winning_team_id: lions.id)
			matchup2_3.update_attributes(winning_team_id: steelers.id)
			Matchup.handle_matchup_outcome!(matchup2_1.id)
			Matchup.handle_matchup_outcome!(matchup2_2.id)
			Matchup.handle_matchup_outcome!(matchup2_3.id)

			# Week 3 Picks

			pick3_3 = Pick.create(pool_entry_id: pool_entry3.id, week_id: week3.id, team_id: steelers.id, matchup_id: matchup3_3.id)
			pick3_8 = Pick.create(pool_entry_id: pool_entry8.id, week_id: week3.id, team_id: lions.id, matchup_id: matchup3_2.id)
			pick3_9 = Pick.create(pool_entry_id: pool_entry9.id, week_id: week3.id, team_id: chargers.id, matchup_id: matchup3_3.id)
			pick3_10 = Pick.create(pool_entry_id: pool_entry10.id, week_id: week3.id, team_id: broncos.id, matchup_id: matchup3_1.id)
			pick3_11 = Pick.create(pool_entry_id: pool_entry11.id, week_id: week3.id, team_id: packers.id, matchup_id: matchup3_2.id)
			pick3_12 = Pick.create(pool_entry_id: pool_entry12.id, week_id: week3.id, team_id: chargers.id, matchup_id: matchup3_3.id)	

			# Handle Week 3 Outcomes

			matchup3_1.update_attributes(winning_team_id: broncos.id)
			matchup3_2.update_attributes(winning_team_id: packers.id)
			matchup3_3.update_attributes(winning_team_id: chargers.id)
			Matchup.handle_matchup_outcome!(matchup3_1.id)
			Matchup.handle_matchup_outcome!(matchup3_2.id)
			Matchup.handle_matchup_outcome!(matchup3_3.id)

			# Week 4 Picks

			pick4_9 = Pick.create(pool_entry_id: pool_entry9.id, week_id: week4.id, team_id: steelers.id, matchup_id: matchup4_3.id)
			pick4_10 = Pick.create(pool_entry_id: pool_entry10.id, week_id: week4.id, team_id: broncos.id, matchup_id: matchup4_1.id)
			pick4_11 = Pick.create(pool_entry_id: pool_entry11.id, week_id: week4.id, team_id: lions.id, matchup_id: matchup4_2.id)
			pick4_12 = Pick.create(pool_entry_id: pool_entry12.id, week_id: week4.id, team_id: steelers.id, matchup_id: matchup4_3.id)	

			# Handle Week 4 Outcomes

			matchup4_1.update_attributes(winning_team_id: vikings.id)
			matchup4_2.update_attributes(winning_team_id: lions.id)
			matchup4_3.update_attributes(winning_team_id: steelers.id)
			Matchup.handle_matchup_outcome!(matchup4_1.id)
			Matchup.handle_matchup_outcome!(matchup4_2.id)
			Matchup.handle_matchup_outcome!(matchup4_3.id)

# create a base admin user so we can login
# For some reason I was only able to do this from the Rails Console...
admin_user = User.create :email => "daveandtree@comcast.net", :password => "#xcDso*RH6A4^Ir", password_confirmation: "#xcDso*RH6A4^Ir", admin: true
admin_user.save!