require 'spec_helper'

describe MatchupsController do
	describe "POST save_week_outcomes" do

		before do
			@admin = create(:admin)
			sign_in :admin, @admin

			@season = Season.create(year: 2014, name: "2014 Season", entry_fee: 50)
			@week = Week.create(season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))
			@pool_entry = PoolEntry.create(user: @admin, team_name: "Test Team", paid: true)

			@broncos = NflTeam.create(name: "Denver Broncos", conference: "NFC", division: "West")
			@vikings = NflTeam.create(name: "Minnesota Vikings", conference: "NFC", division: "North")
			@matchup = Matchup.create(week_id: @week.id, home_team: @broncos, away_team: @vikings, game_time: DateTime.new(2014,8,10,11))
		end

		it "knocks out a pool entry if the selected matchup is a tie" do
			@pick = Pick.create(pool_entry: @pool_entry, week: @week, team_id: @vikings.id)
			@matchup.update_attributes(tie: true)
			post :save_outcome, week_id: @week.id, matchup: @matchup, format: :json
			@pool_entry.reload
			expect(@pool_entry.knocked_out).to eq(true)
		end

		it "knocks out a pool entry if the selected team loses" do
			@pick = Pick.create(pool_entry: @pool_entry, week: @week, team_id: @vikings.id)
			@matchup.update_attributes(winning_team_id: @broncos.id)
			post :save_outcome, week_id: @week.id, matchup: @matchup, format: :json
			@pool_entry.reload
			expect(@pool_entry.knocked_out).to eq(true)
		end

		it "does not knock out a pool entry if the selected team wins" do
			@pick = Pick.create(pool_entry: @pool_entry, week: @week, team_id: @vikings.id)
			@matchup.update_attributes(winning_team_id: @vikings.id)
			post :save_outcome, week_id: @week.id, matchup: @matchup, format: :json
			@pool_entry.reload
			expect(@pool_entry.knocked_out).to eq(false)
		end
	end
end