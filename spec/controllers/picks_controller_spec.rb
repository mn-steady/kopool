require 'spec_helper'

describe PicksController do

  describe "GET index" do

  	before do
			@user = create(:user, admin: true)
			sign_in @user

			@season = Season.create(year: 2014, name: "2014 Season", entry_fee: 50)
			@week = Week.create(season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))
			@pool_entry1 = PoolEntry.create(user: @user, team_name: "Test Team", paid: true)
			@pool_entry2 = PoolEntry.create(user: @user, team_name: "Team Two", paid: true)

			@broncos = NflTeam.create(name: "Denver Broncos", conference: "NFC", division: "West")
			@vikings = NflTeam.create(name: "Minnesota Vikings", conference: "NFC", division: "North")
			@matchup = Matchup.create(week_id: @week.id, home_team: @broncos, away_team: @vikings, game_time: DateTime.new(2014,8,10,11))
		end

  	it "returns the user's picks from this season" do
  		pick1 = Pick.create(pool_entry: @pool_entry1, week: @week, team_id: @vikings.id)
  		pick2 = Pick.create(pool_entry: @pool_entry2, week: @week, team_id: @broncos.id)

  		get :index, week_id: @week.id, format: :json
      picks_returned = JSON.parse(response.body)

  		expect(picks_returned[0]['id']).to eq(pick1.id)
      expect(picks_returned[1]['id']).to eq(pick2.id)
  	end

  	it "does not include another user's picks in response" do
      @another_user = create(:user)
      @another_pool_entry = PoolEntry.create(user: @another_user, team_name: "Not Yours", paid: true)
      pick1 = Pick.create(pool_entry: @pool_entry1, week: @week, team_id: @vikings.id)
      pick2 = Pick.create(pool_entry: @another_pool_entry, week: @week, team_id: @broncos.id)

      get :index, week_id: @week.id, format: :json
      picks_returned = JSON.parse(response.body)
      expect(picks_returned.length).to eq(1)
      expect(picks_returned[0]['id']).to eq(pick1.id)
  	end

  	it "does not include picks from a different season in response" do
      @last_season = Season.create(year: 2014, name: "2013 Season", entry_fee: 5)
      @old_week = Week.create(season: @last_season, week_number: 1, start_date: DateTime.new(2013, 8, 5), deadline: DateTime.new(2013, 8, 8), end_date: DateTime.new(2013, 8, 11))
      @old_pool_entry = PoolEntry.create(user: @user, season: @last_season, team_name: "Ancient History", paid: true)
      pick1 = Pick.create(pool_entry: @pool_entry1, week: @week, team_id: @vikings.id)
      old_pick1 = Pick.create(pool_entry: @old_pool_entry, week: @old_week, team_id: @broncos.id)

      get :index, week_id: @week.id, format: :json
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
      @week = Week.create(season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))
      @pool_entry1 = PoolEntry.create(user: @user, team_name: "Test Team", paid: true)

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
            format: :json
          }

          post :create, pick_params
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
            format: :json
          }

          post :create, pick_params
          pick_returned = JSON.parse(response.body)
          expect(Pick.count).to eq(0)
          expect(pick_returned[0]['error']).to match /pool_entry_id can't be blank/
        end

	  		it "does not let you save two picks for same PoolEntry in one week" do
          pick_params = {
            week_id: @week.id,
            pool_entry_id: @pool_entry1.id,
            team_id: @vikings.id,
            format: :json
          }

          post :create, pick_params
          pick_returned = JSON.parse(response.body)
          expect(Pick.count).to eq(1)

          @week.close_week_for_picks!

          pick_params = {
            week_id: @week.id,
            pool_entry_id: @pool_entry1.id,
            team_id: @broncos.id,
            format: :json
          }

          post :create, pick_params
          pick_returned = JSON.parse(response.body)
          expect(Pick.count).to eq(1)
          expect(pick_returned[0]['error']).to match /pool_entry_id has already been taken/
        end


        it "does not overwrite pick if you try to change after the week is closed" do
          pick_params = {
            week_id: @week.id,
            pool_entry_id: @pool_entry1.id,
            team_id: @vikings.id,
            format: :json
          }

          post :create, pick_params
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

          put :update, pick_params
          pick_returned = JSON.parse(response.body)
          expect(pick_returned[0]['error']).to match /You cannot change a pick when the week is closed/
          expect(Pick.count).to eq(1)
          expect(Pick.last.team_id).to eq(@vikings.id)
        end

	  	end

	  end

	  context "with a knocked out pool entry" do
	  	it "does not save the pick" do
        pick1 = Pick.create(pool_entry: @pool_entry1, week: @week, team_id: @vikings.id)
        @pool_entry1.update_attributes(knocked_out: true, knocked_out_week_id: @week.id)

         pick_params = {
            id: pick1['id'],
            week_id: @week.id,
            pool_entry_id: @pool_entry1.id,
            team_id: @broncos.id,
            format: :json
          }

        put :update, pick_params
        pick_returned = JSON.parse(response.body)
        expect(pick_returned[0]['error']).to match /You cannot change a pick when knocked out/
        expect(Pick.count).to eq(1)
        expect(Pick.last.team_id).to eq(@vikings.id)
      end
	  end
  end

  describe "GET missing_picks" do
  	# Will we want this in pool_entries_controller since we'll search
  	# for pool_entries without a pick for that week?
  	it "sets @missing_picks to the missing picks from the current week"
  	it "does not include picks from a later week in @missing_picks"
  	it "does not include completed picks in @missing_picks"
  end


  describe "GET week_picks" do

  	before do
			@user = create(:user, admin: true)
			sign_in :user, @user

			@season = Season.create(year: 2014, name: "2014 Season", entry_fee: 50)
			@week = Week.create(season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))
			@pool_entry1 = PoolEntry.create(user: @user, team_name: "Test Team", paid: true)
			@pool_entry2 = PoolEntry.create(user: @user, team_name: "Team Two", paid: true)

			@broncos = NflTeam.create(name: "Denver Broncos", conference: "NFC", division: "West")
			@vikings = NflTeam.create(name: "Minnesota Vikings", conference: "NFC", division: "North")
			@matchup = Matchup.create(week_id: @week.id, home_team: @broncos, away_team: @vikings, game_time: DateTime.new(2014,8,10,11))
		end

		context "week is closed for picks" do

			before do
				@week.update_attributes(open_for_picks: false)
			end

			it "returns the picks from this week" do
	  		pick1 = Pick.create(pool_entry: @pool_entry1, week: @week, team_id: @vikings.id)
	  		pick2 = Pick.create(pool_entry: @pool_entry2, week: @week, team_id: @broncos.id)
	  		get :week_picks, week_id: @week.id, format: :json
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
	  		get :week_picks, week_id: @week.id, format: :json
	  		expect(response.status).to eq(Rack::Utils.status_code(:bad_request))

	  		returned = JSON.parse(response.body)

	  		expect(returned[0]['error']).to be_present
			end
		end
  end
end