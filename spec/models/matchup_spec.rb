require 'spec_helper'

RSpec.describe Matchup, type: :model do

  it { should belong_to :week }
  it { should belong_to :home_team }
  it { should belong_to :away_team }

  it { should validate_presence_of :week }
  it { should validate_presence_of :home_team }
  it { should validate_presence_of :away_team }

  context "matchup complete" do

    before(:each) do
            @user = create(:user)
      @season = create(:season)
      @week16 = Week.create(week_number: 16, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season: @season)
      @week17 = Week.create(week_number: 17, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season: @season)
      @web_state = create(:web_state, week_id: @week16.id, season_id: @season.id)
      @team1 = FactoryBot.create(:nfl_team)
      @team2 = FactoryBot.create(:nfl_team)
      @team3 = FactoryBot.create(:nfl_team)
      @team4 = FactoryBot.create(:nfl_team)

      @monday_matchup = Matchup.create(game_time: DateTime.new(2017,8,14,15,00), week_id: @week16.id, home_team_id: @team1.id, away_team_id: @team2.id)
      @thursday_matchup = Matchup.create(game_time: DateTime.new(2017,8,17,15,00), week_id: @week16.id, home_team_id: @team3.id, away_team_id: @team4.id)

      @pool_entry_1 = FactoryBot.create(:pool_entry, team_name: "We Will Lose Home (tie)", season: @season, user: @user)
      @pool_entry_2 = FactoryBot.create(:pool_entry, team_name: "We Will Lose Away (tie)", season: @season, user: @user)
      @pool_entry_3 = FactoryBot.create(:pool_entry, team_name: "We Will Win (Home)", season: @season, user: @user)
      @pool_entry_4 = FactoryBot.create(:pool_entry, team_name: "We Will Lose (Away)", season: @season, user: @user)

      @pick1 = FactoryBot.create(:pick, pool_entry: @pool_entry_1, week: @week16, nfl_team: @monday_matchup.home_team, matchup: @monday_matchup)
      @pick2 = FactoryBot.create(:pick, pool_entry: @pool_entry_2, week: @week16, nfl_team: @monday_matchup.away_team, matchup: @monday_matchup)
      @pick3 = FactoryBot.create(:pick, pool_entry: @pool_entry_3, week: @week16, nfl_team: @thursday_matchup.home_team, matchup: @thursday_matchup)
      @pick4 = FactoryBot.create(:pick, pool_entry: @pool_entry_4, week: @week16, nfl_team: @thursday_matchup.away_team, matchup: @thursday_matchup)

    end

    it "should handle knockouts according to tie, win, loss rules" do
      @monday_matchup.update_attributes(completed: true, tie: true)
      @thursday_matchup.update_attributes(completed: true, winning_team_id: @thursday_matchup.home_team.id)

      Matchup.handle_matchup_outcome!(@monday_matchup.id)
      Matchup.handle_matchup_outcome!(@thursday_matchup.id)

      expect(PoolEntry.where(knocked_out: true).count).to eq(3)
      expect(PoolEntry.where(knocked_out: false).count).to eq(1)
    end

  end

end
