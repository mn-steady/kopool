require 'spec_helper'

describe PicksController do

  describe "GET index" do

  	before do
			@user = create(:user, admin: true)
			sign_in @user

			@season = Season.create!(year: 2014, name: "2014 Season", entry_fee: 50)
			@week = FactoryBot.create(:week, season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))
			@pool_entry1 = PoolEntry.create!(user: @user, team_name: "Test Team", paid: true, season: @season)
			@pool_entry2 = PoolEntry.create!(user: @user, team_name: "Team Two", paid: true, season: @season)

			@broncos = NflTeam.create!(name: "Denver Broncos", conference: "NFC", division: "West")
			@vikings = NflTeam.create!(name: "Minnesota Vikings", conference: "NFC", division: "North")
			@matchup = Matchup.create!(week_id: @week.id, home_team: @broncos, away_team: @vikings, game_time: DateTime.new(2014,8,10,11))
		end

    it "returns the user's picks from this season" do
      pick1 = @pool_entry1.picks.create(week: @week, nfl_team: @vikings, matchup: @matchup)
      pick2 = @pool_entry2.picks.create(week: @week, nfl_team: @broncos, matchup: @matchup)

      get :index, params: { week_id: @week.id }, format: :json
      picks_returned = JSON.parse(response.body)

      expect(picks_returned[0]['id']).to eq(pick1.id)
      expect(picks_returned[1]['id']).to eq(pick2.id)
    end

  	it "does not include another user's picks in response" do
      @another_user = create(:user)
      @another_pool_entry = PoolEntry.create(user: @another_user, team_name: "Not Yours", paid: true)
      pick1 = Pick.create(pool_entry: @pool_entry1, week: @week, team_id: @vikings.id, matchup_id: @matchup.id)
      pick2 = Pick.create(pool_entry: @another_pool_entry, week: @week, team_id: @broncos.id, matchup_id: @matchup.id)

      get :index, params: { week_id: @week.id }, format: :json
      picks_returned = JSON.parse(response.body)
      expect(picks_returned.length).to eq(1)
      expect(picks_returned[0]['id']).to eq(pick1.id)
  	end

  	it "does not include picks from a different season in response" do
      @last_season = Season.create(year: 2014, name: "2013 Season", entry_fee: 5)
      @old_week = Week.create(season: @last_season, week_number: 1, start_date: DateTime.new(2013, 8, 5), deadline: DateTime.new(2013, 8, 8), end_date: DateTime.new(2013, 8, 11))
      @old_pool_entry = PoolEntry.create(user: @user, season: @last_season, team_name: "Ancient History", paid: true)
      pick1 = Pick.create(pool_entry: @pool_entry1, week: @week, team_id: @vikings.id, matchup_id: @matchup.id)
      old_pick1 = Pick.create(pool_entry: @old_pool_entry, week: @old_week, team_id: @broncos.id, matchup_id: @matchup.id)

      get :index, params: { week_id: @week.id }, format: :json
      picks_returned = JSON.parse(response.body)
      expect(picks_returned.length).to eq(1)
      expect(picks_returned[0]['id']).to eq(pick1.id)
    end
  end

  describe "POST create" do

    before do
      @user = create(:user, admin: true)
      sign_in @user

      @season = Season.create(year: 2014, name: "2014 Season", entry_fee: 50)
      @week = FactoryBot.create(:week, season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))
      @pool_entry1 = PoolEntry.create(user: @user, team_name: "Test Team", paid: true, season: @season)

      @broncos = NflTeam.create(name: "Denver Broncos", conference: "NFC", division: "West")
      @vikings = NflTeam.create(name: "Minnesota Vikings", conference: "NFC", division: "North")
      @matchup = Matchup.create(week_id: @week.id, home_team: @broncos, away_team: @vikings, game_time: DateTime.new(2014,8,10,11))
    end

  	context "with a valid pool entry" do

	  	context "with valid input" do
	  		it "persists the new pick" do
          pick_params = {
            week_id: @week.id,
            pool_entry_id: @pool_entry1.id,
            team_id: @vikings.id,
            matchup_id: @matchup.id,
          }

          post :create, params: pick_params, format: :json
          pick_returned = JSON.parse(response.body)
          expect(Pick.count).to eq(1)
          expect(pick_returned['pool_entry_id']).to eq(@pool_entry1.id)
        end
	  	end


	  	context "with invalid input" do # i.e. after deadline (should I create separate tests?)
	  		it "does not create a new pick" do
          pick_params = {
            week_id: @week.id,
            team_id: @vikings.id,
          }

          post :create, params: pick_params, format: :json
          pick_returned = JSON.parse(response.body)
          expect(Pick.count).to eq(0)
          expect(pick_returned[0]['error']).to match /pool_entry_id can't be blank/
        end

	  		it "does not let you save two picks for same PoolEntry in one week" do
          pick_params = {
            week_id: @week.id,
            pool_entry_id: @pool_entry1.id,
            team_id: @vikings.id,
            matchup_id: @matchup.id,
          }

          post :create, params: pick_params, format: :json
          pick_returned = JSON.parse(response.body)
          expect(Pick.count).to eq(1)

          @week.close_week_for_picks!

          pick_params = {
            week_id: @week.id,
            pool_entry_id: @pool_entry1.id,
            team_id: @broncos.id,
            format: :json
          }

          post :create, params: pick_params
          pick_returned = JSON.parse(response.body)
          expect(Pick.count).to eq(1)
          expect(pick_returned[0]['error']).to match /pool_entry_id has already been taken/
        end


        it "does not overwrite pick if you try to change after the week is closed" do
          pick_params = {
            week_id: @week.id,
            pool_entry_id: @pool_entry1.id,
            team_id: @vikings.id,
            matchup_id: @matchup.id,
            format: :json
          }

          post :create, params: pick_params
          pick_returned = JSON.parse(response.body)
          expect(Pick.count).to eq(1)

          @week.close_week_for_picks!

          pick_params = {
            id: pick_returned['id'],
            week_id: @week.id,
            pool_entry_id: @pool_entry1.id,
            team_id: @broncos.id,
            format: :json
          }

          put :update, params: pick_params
          pick_returned = JSON.parse(response.body)
          expect(pick_returned[0]['error']).to match /You cannot change a pick when the week is closed/
          expect(Pick.count).to eq(1)
          expect(Pick.last.team_id).to eq(@vikings.id)
        end
	  	end
	  end

	  context "with a knocked out pool entry" do
	  	it "does not save the pick" do
        pick1 = Pick.create(pool_entry: @pool_entry1, week: @week, team_id: @vikings.id, matchup_id: @matchup.id)
        @pool_entry1.update_attributes(knocked_out: true, knocked_out_week_id: @week.id)

          pick_params = {
            id: pick1['id'],
            week_id: @week.id,
            pool_entry_id: @pool_entry1.id,
            team_id: @broncos.id,
            format: :json
          }

        put :update, params: pick_params
        pick_returned = JSON.parse(response.body)
        expect(pick_returned[0]['error']).to match /You cannot change a pick when knocked out/
        expect(Pick.count).to eq(1)
        expect(Pick.last.team_id).to eq(@vikings.id)
      end
	  end
  end

  describe "POST create_or_update_pick" do

    before do
      @user = create(:user, admin: true)
      sign_in @user

      @season = Season.create(year: 2014, name: "2014 Season", entry_fee: 50)
      @week = FactoryBot.create(:week, season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))
      @pool_entry1 = PoolEntry.create(user: @user, team_name: "Test Team", paid: true, season: @season)

      @broncos = NflTeam.create(name: "Denver Broncos", conference: "NFC", division: "West")
      @vikings = NflTeam.create(name: "Minnesota Vikings", conference: "NFC", division: "North")
      @matchup = Matchup.create(week_id: @week.id, home_team: @broncos, away_team: @vikings, game_time: DateTime.new(2014,8,10,11))
    end

    context "with an existing pick" do
      it "does save the new pick" do
        pick1 = Pick.create(pool_entry: @pool_entry1, week: @week, team_id: @vikings.id, matchup_id: @matchup.id)

         pick_params = {
            week_id: @week.id,
            pool_entry_id: @pool_entry1.id,
            team_id: @broncos.id,
            matchup_id: @matchup.id,
            format: :json
          }

        put :create_or_update_pick, params: pick_params
        pick_returned = JSON.parse(response.body)

        expect(Pick.count).to eq(1)
        expect(Pick.last.team_id).to eq(@broncos.id)
      end
    end

    context "without an existing pick" do
      it "does save the new pick" do

         pick_params = {
            week_id: @week.id,
            pool_entry_id: @pool_entry1.id,
            team_id: @broncos.id,
            matchup_id: @matchup.id,
            format: :json
          }

        put :create_or_update_pick, params: pick_params
        pick_returned = JSON.parse(response.body)

        expect(Pick.count).to eq(1)
        expect(Pick.last.team_id).to eq(@broncos.id)
      end

      it "does not save a pick if the pool entry is knocked out" do
        @pool_entry1.update_attributes(knocked_out: true)

        pick_params = {
            week_id: @week.id,
            pool_entry_id: @pool_entry1.id,
            team_id: @broncos.id,
            format: :json
          }

        put :create_or_update_pick, params: pick_params
        pick_returned = JSON.parse(response.body)

        expect(Pick.count).to eq(0)
        expect(pick_returned).to have_key("error")
        expect(response.status).to eq(Rack::Utils.status_code(:bad_request))
      end
    end
  end

  describe "GET week_picks" do

  	before do
			@user = create(:user, admin: true)
      sign_in(@user, scope: :user)

			@season = Season.create(year: 2014, name: "2014 Season", entry_fee: 50)
			@week = FactoryBot.create(:week, season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))
			@pool_entry1 = PoolEntry.create(user: @user, team_name: "Test Team", paid: true, season: @season)
			@pool_entry2 = PoolEntry.create(user: @user, team_name: "Team Two", paid: true, season: @season)

			@broncos = NflTeam.create(name: "Denver Broncos", conference: "NFC", division: "West")
			@vikings = NflTeam.create(name: "Minnesota Vikings", conference: "NFC", division: "North")
			@matchup = Matchup.create(week_id: @week.id, home_team: @broncos, away_team: @vikings, game_time: DateTime.new(2014,8,10,11))
		end

		context "week is closed for picks" do

			before do
				@week.update_attributes(open_for_picks: false)
			end

			it "returns the picks from this week" do
	  		pick1 = Pick.create(pool_entry: @pool_entry1, week: @week, team_id: @vikings.id, matchup_id: @matchup.id)
	  		pick2 = Pick.create(pool_entry: @pool_entry2, week: @week, team_id: @broncos.id, matchup_id: @matchup.id)
	  		get :week_picks, params: { week_id: @week.id }, format: :json
	  		expect(response.status).to eq(Rack::Utils.status_code(:ok))

	  		returned = JSON.parse(response.body)

	  		expect(returned.count).to eq(2)
	  		expect(returned.first['nfl_team']['name']).to eq("Minnesota Vikings")
	  	end
  	end

		context "week is open for picks" do

			it "returns an error message" do
				pick1 = Pick.create(pool_entry: @pool_entry1, week: @week, team_id: @vikings.id)
	  		pick2 = Pick.create(pool_entry: @pool_entry2, week: @week, team_id: @broncos.id)
	  		get :week_picks, params: { week_id: @week.id }, format: :json
	  		expect(response.status).to eq(Rack::Utils.status_code(:bad_request))

	  		returned = JSON.parse(response.body)

	  		expect(returned[0]['error']).to be_present
			end
		end
  end

  describe "GET sorted_picks" do

    before do
      @user = create(:user)
      sign_in(@user, scope: :user)

      @season = Season.create(year: 2014, name: "2014 Season", entry_fee: 50)
      @week = FactoryBot.create(:week, season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))
      @pool_entry1 = PoolEntry.create(user: @user, team_name: "Test Team", paid: true, season: @season)
      @pool_entry2 = PoolEntry.create(user: @user, team_name: "Team Two", paid: true, season: @season)
      @pool_entry3 = PoolEntry.create(user: @user, team_name: "Team Three", paid: true, season: @season)
      @pool_entry4 = PoolEntry.create(user: @user, team_name: "Team Four", paid: true, season: @season)
      @pool_entry5 = PoolEntry.create(user: @user, team_name: "Team Five", paid: true, season: @season)
      @pool_entry6 = PoolEntry.create(user: @user, team_name: "Team Six", paid: true, season: @season)
      @pool_entry7 = PoolEntry.create(user: @user, team_name: "Team Seven", paid: true, season: @season)

      @broncos = NflTeam.create(name: "Denver Broncos", conference: "NFC", division: "West")
      @vikings = NflTeam.create(name: "Minnesota Vikings", conference: "NFC", division: "North")
      @matchup = Matchup.create(week_id: @week.id, home_team: @broncos, away_team: @vikings, game_time: DateTime.new(2014,8,10,11))

      @colts = NflTeam.create(name: "Indianapolis Colts", conference: "NFC", division: "West")
      @steelers = NflTeam.create(name: "Pittsburg Steelers", conference: "NFC", division: "North")
      @matchup2 = Matchup.create(week_id: @week.id, home_team: @colts, away_team: @steelers, game_time: DateTime.new(2014,8,12,11))

      @pickB1 = Pick.create(pool_entry: @pool_entry4, week: @week, team_id: @broncos.id, matchup_id: @matchup.id)
      @pickB2 = Pick.create(pool_entry: @pool_entry5, week: @week, team_id: @broncos.id, matchup_id: @matchup.id)
      @pickC1 = Pick.create(pool_entry: @pool_entry6, week: @week, team_id: @colts.id, matchup_id: @matchup2.id)
      @pickS1 = Pick.create(pool_entry: @pool_entry7, week: @week, team_id: @steelers.id, matchup_id: @matchup2.id)
      @pickV1 = Pick.create(pool_entry: @pool_entry1, week: @week, team_id: @vikings.id, matchup_id: @matchup.id)
      @pickV2 = Pick.create(pool_entry: @pool_entry2, week: @week, team_id: @vikings.id, matchup_id: @matchup.id)
      @pickV3 = Pick.create(pool_entry: @pool_entry3, week: @week, team_id: @vikings.id, matchup_id: @matchup.id)
    end

    context "week is closed for picks" do

      it "returns a sorted hash in descending order" do

        @week.update_attributes(open_for_picks: false)

        get :sorted_picks, params: { week_id: @week.id }, format: :json

        sorted_picks = JSON.parse(response.body)

        expect(sorted_picks[0][0]).to eq(@vikings.name)
        expect(sorted_picks[1][0]).to eq(@broncos.name)
        expect(sorted_picks[2][0]).to eq(@colts.name)
        expect(sorted_picks[3][0]).to eq(@steelers.name)
        expect(sorted_picks[0][1]).to eq(3)
        expect(sorted_picks[1][1]).to eq(2)
        expect(sorted_picks[2][1]).to eq(1)
        expect(sorted_picks[3][1]).to eq(1)

      end

      it "doesn't return teams with no picks" do
        @giants = NflTeam.create(name: "New York Giants", conference: "NFC", division: "West")
        @chargers = NflTeam.create(name: "San Diego Chargers", conference: "NFC", division: "North")
        @matchup3 = Matchup.create(week_id: @week.id, home_team: @giants, away_team: @chargers, game_time: DateTime.new(2014,8,14,11))


        @week.update_attributes(open_for_picks: false)

        get :sorted_picks, params: { week_id: @week.id }, format: :json

        sorted_picks = JSON.parse(response.body)

        expect(sorted_picks[0][0]).to eq(@vikings.name)
        expect(sorted_picks[1][0]).to eq(@broncos.name)
        expect(sorted_picks[2][0]).to eq(@colts.name)
        expect(sorted_picks[3][0]).to eq(@steelers.name)
        expect(sorted_picks[0][1]).to eq(3)
        expect(sorted_picks[1][1]).to eq(2)
        expect(sorted_picks[2][1]).to eq(1)
        expect(sorted_picks[3][1]).to eq(1)
        expect(sorted_picks.length).to eq(4)
      end

    end

    context "week is open for picks" do

      it "returns an error message and bad request status" do
        @week.update_attributes(open_for_picks: true)

        get :sorted_picks, params: { week_id: @week.id }, format: :json

        returned = JSON.parse(response.body)

        expect(response.status).to eq(Rack::Utils.status_code(:bad_request))
        expect(returned[0]['error']).to be_present
      end
    end

  end
end
