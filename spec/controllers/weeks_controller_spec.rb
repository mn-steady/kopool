require 'spec_helper'

describe WeeksController do

  describe "GET week_results" do

    before (:each) do
      @regular_guy = create(:user)
      sign_in @regular_guy

      @season = Season.create(year: 2014, name: "2014 Season", entry_fee: 50)
      @week = Week.create(season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))

      @web_state = FactoryGirl.create(:web_state, current_week: @week)
      @pool_entry = FactoryGirl.create(:pool_entry, user: @regular_guy, team_name: "Test Team", paid: true, season: @season)

      @broncos = NflTeam.create(name: "Denver Broncos", conference: "NFC", division: "West")
      @vikings = NflTeam.create(name: "Minnesota Vikings", conference: "NFC", division: "North")
      @matchup = Matchup.create(week_id: @week.id, home_team: @broncos, away_team: @vikings, game_time: DateTime.new(2014,8,10,11))

      @pick1 = FactoryGirl.create(:pick, pool_entry: @pool_entry, week: @week, nfl_team: @vikings, matchup: @matchup)
    end


    it "won't show results unless week is closed for picks" do
      get :week_results, week_id: @week.id, format: :json
      expect(response.status).to eq(Rack::Utils.status_code(:bad_request))
      expect(response.body).to match(/You can't see the results for this week until this week's games have started/)
    end


    it "returns still alive" do
      @week.update_attributes(open_for_picks: false)
      get :week_results, week_id: @week.id, format: :json
      expect(response.status).to eq(Rack::Utils.status_code(:ok))

      returned = JSON.parse(response.body)

      expect(returned.count).to eq(4)

      still_alive = returned[0]
      expect(still_alive[0]['id']).to eq(@pool_entry.id)
      expect(still_alive[0]['team_name']).to eq(@pool_entry.team_name)

      alive_team = still_alive[0]['nfl_team']
      expect(alive_team['nfl_team_id']).to eq(@pick1.nfl_team.id)
      expect(alive_team['logo_url_small']).to eq(@pick1.nfl_team.logo_url_small)

      knocked_out_this_week = returned[1]
      expect(knocked_out_this_week.count).to eq(0)

      knocked_out_previously = returned[2]
      expect(knocked_out_previously.count).to eq(0)

      unmatched = returned[3]
      expect(unmatched.count).to eq(0)


    end
  end


end