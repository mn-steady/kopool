require 'spec_helper'

describe PoolEntriesController do

	describe "POST create" do

		before do
			@season = Season.create(year: 2014, name: "2014 Season", entry_fee: 50)
      @week = Week.create(season: @season, week_number: 1, open_for_picks: true, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))
      @web_state = FactoryGirl.create(:web_state, current_week: @week)
		end

		context "with valid input" do

			before do
				@user = create(:user, admin: true)
				sign_in :user, @user
			end

			it "saves the new pool entry" do
				post :create, user: @user, team_name: "Test Team", format: :json
				expect(PoolEntry.first.team_name).to eq("Test Team")
			end

			it "associates the new pool entry with the current season" do
				post :create, user: @user, team_name: "Test Team", format: :json
				expect(PoolEntry.first.season_id).to eq(@season.id)
			end

		end

		context "with invalid input" do

			before do
				@user = create(:user, admin: true)
				sign_in :user, @user
			end

			it "will not create a new pool entry after the first week is closed for picks" do
				@week.close_week_for_picks!
				post :create, user: @user, team_name: "Test Team", format: :json
				expect(response.status).to eq(Rack::Utils.status_code(:bad_request))
				expect(PoolEntry.count).to eq(0)
			end

			it "will not create a new pool entry after the first week" do
				@week.update_attributes(week_number: 2)
				post :create, user: @user, team_name: "Test Team", format: :json
				expect(response.status).to eq(Rack::Utils.status_code(:bad_request))
				expect(PoolEntry.count).to eq(0)
			end

		end

		context "deleting persisted pool entries (possible future functionality)" do

			before do
				@regular_guy = create(:user)
				sign_in @regular_guy
			end

			it "will let a user delete his/her own pool entries if the first week is open for picks" do
				@params = { 'team_name' => "Test Team", 'format' => 'json'}
				post :create, @params
				expect(PoolEntry.first.team_name).to eq("Test Team")
				pool_entry = PoolEntry.first
				@params = { 'id' => pool_entry.id, 'format' => 'json'}
				delete :destroy, @params
				expect(response.status).to eq(Rack::Utils.status_code(:ok))
				expect(PoolEntry.count).to eq(0)
			end

			it "will not let one user delete another users pool entries" do
				@params = { 'team_name' => "Test Team", 'format' => 'json'}
				post :create, @params
				expect(PoolEntry.first.team_name).to eq("Test Team")
				pool_entry = PoolEntry.first
				sign_out @regular_guy

				@different_guy = create(:user, email: 'different@test.com')
				sign_in @different_guy
				@params = { 'id' => pool_entry.id, 'format' => 'json'}
				delete :destroy, @params
				expect(response.status).to eq(Rack::Utils.status_code(:internal_server_error))
				expect(PoolEntry.count).to eq(1)
			end

			it "will not delete a new pool entry after the first week" do
				@params = { 'team_name' => "Test Team", 'format' => 'json'}
				post :create, @params
				expect(PoolEntry.first.team_name).to eq("Test Team")
				pool_entry = PoolEntry.first

				@week.update_attributes(week_number: 2)

				@params = { 'id' => pool_entry.id, 'format' => 'json'}
				delete :destroy, @params
				expect(response.status).to eq(Rack::Utils.status_code(:internal_server_error))
				expect(PoolEntry.count).to eq(1)
			end
		end
	end

	describe "GET #pool_entries_and_picks" do
		before do
			@user = create(:user)
			sign_in @user

			@season = Season.create(year: 2014, name: "2014 Season", entry_fee: 50)
			@week = Week.create(season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))
			@web_state = create(:web_state, week_id: @week.id)
			@pool_entry1 = PoolEntry.create(user: @user, team_name: "Test Team", paid: true, season_id: @season.id)
			@pool_entry2 = PoolEntry.create(user: @user, team_name: "Team Two", paid: true, season_id: @season.id)

			@broncos = NflTeam.create(name: "Denver Broncos", conference: "NFC", division: "West")
			@vikings = NflTeam.create(name: "Minnesota Vikings", conference: "NFC", division: "North")
			@matchup = Matchup.create(week_id: @week.id, home_team: @broncos, away_team: @vikings, game_time: DateTime.new(2014,8,10,11))
		end

  	it "returns nfl teams for both pool entries when picks exist" do
  		pick1 = Pick.create(pool_entry: @pool_entry1, week: @week, team_id: @vikings.id)
  		pick2 = Pick.create(pool_entry: @pool_entry2, week: @week, team_id: @broncos.id)

  		get :pool_entries_and_picks, week_id: @week.id, format: :json
      pool_entries_and_teams = JSON.parse(response.body)

  		expect(pool_entries_and_teams[0]['id']).to eq(@pool_entry1.id)
  		expect(pool_entries_and_teams[0]['team_name']).to eq(@pool_entry1.team_name)
  		expect(pool_entries_and_teams[0]['nfl_team']).to eq({"nfl_team_id" => @vikings.id, "logo_url_small" => @vikings.logo_url_small})
      expect(pool_entries_and_teams[1]['id']).to eq(@pool_entry2.id)
  		expect(pool_entries_and_teams[1]['team_name']).to eq(@pool_entry2.team_name)
  		expect(pool_entries_and_teams[1]['nfl_team']).to eq({"nfl_team_id" => @broncos.id, "logo_url_small" => @broncos.logo_url_small})
  	end

  	it "returns pool entries but no nfl team when picks don't exist" do

  		get :pool_entries_and_picks, week_id: @week.id, format: :json
      pool_entries_and_teams = JSON.parse(response.body)

  		expect(pool_entries_and_teams[0]).to eq({"id"=>@pool_entry1.id, "team_name"=>@pool_entry1.team_name, "nfl_team"=>{}})
  		expect(pool_entries_and_teams[1]).to eq({"id"=>@pool_entry2.id, "team_name"=>@pool_entry2.team_name, "nfl_team"=>{}})
  	end

  	it "returns an error message when the week is closed for picks" do
  		@week.open_for_picks = false
  		@week.save!

  		get :pool_entries_and_picks, week_id: @week.id, format: :json
      pool_entries_and_teams = JSON.parse(response.body)

      expect(pool_entries_and_teams).to have_key("error")
      expect(response.status).to eq(Rack::Utils.status_code(:bad_request))
  	end

  	it "returns an error message when no active pool entries are found" do
  		@pool_entry1.update_attributes(knocked_out: true)
  		@pool_entry2.update_attributes(knocked_out: true)

  		get :pool_entries_and_picks, week_id: @week.id, format: :json
      pool_entries_and_teams = JSON.parse(response.body)

      expect(pool_entries_and_teams).to have_key("error")
      expect(response.status).to eq(Rack::Utils.status_code(:bad_request))
  	end
	end
end