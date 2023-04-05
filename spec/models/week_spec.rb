require 'spec_helper'

RSpec.describe Week, type: :model do

  it { should have_many :matchups }
  it { should belong_to :season }

  it { should validate_presence_of :week_number }
  it { should validate_presence_of :start_date }
  it { should validate_presence_of :end_date }
  it { should validate_presence_of :deadline }
  it { should validate_presence_of :season_id }


  describe "#week_number unique in season" do
    it "should not allow you to save a dup week_number in the same season" do
      season = create(:season)
      week1 = FactoryBot.create(:week, week_number: 5, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season: season)
      week1.save!
      week2 = Week.create(week_number: 5, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season: season)
      expect {
        week2.save!
      }.to raise_error ActiveRecord::RecordInvalid
    end
    it "should allow you to save two weeks with dup week number in different season" do
      season = create(:season)
      week1 = FactoryBot.create(:week, week_number: 5, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season: season)
      week1.save!
      season_2 = create(:season, year: season.year+1)
      week2 = FactoryBot.create(:week, week_number: 5, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season_id: season_2.id)
      expect {
        week2.save!
      }.not_to raise_error
    end
  end

  describe "#close_week_for_picks" do
  	it "should set open_for_picks for the passed in week to false" do
  		season = create(:season)
  		week1 = FactoryBot.create(:week, week_number: 1, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season: season)
  		#week2 = Week.create(week_number: 2, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season_id: season.id)
  		week1.close_week_for_picks!

      findit = Week.where(week_number: 1).first
  		expect(findit.open_for_picks).to eq(false)
  	end
  	it "should not set open_for_picks for other weeks to false" do
  		season = create(:season)
  		week1 = FactoryBot.create(:week, week_number: 1, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season: season)
  		week2 = FactoryBot.create(:week, week_number: 2, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season: season)
  		week1.close_week_for_picks!
  		expect(week2.open_for_picks).to eq(true)
  	end
  end

  describe "#move_to_next_week" do
    it "should not advance the week at the last week of the season" do
      season = create(:season)
      week16 = FactoryBot.create(:week, week_number: 16, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season: season)
      week17 = FactoryBot.create(:week, week_number: 17, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season: season)
      web_state = create(:web_state, week_id: week17.id, season_id: season.id)
      week17.move_to_next_week!
      expect(web_state.reload.week_id).to eq(week17.id)
      expect(Week.where(id: week17.id).first.open_for_picks).to eq(false)
    end

    it "should automatically open the next week for picks" do
      season = create(:season)
      week1 = FactoryBot.create(:week, week_number: 10, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season: season)
      week2 = FactoryBot.create(:week, week_number: 11, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season: season)
      web_state = create(:web_state, week_id: week1.id, season_id: season.id)
      week1.move_to_next_week!
      expect(web_state.reload.week_id).to eq(week2.id)
      expect(Week.where(id: week2.id).first.open_for_picks).to eq(true)
    end

    it "should affect only the proper season's week if multiple seasons are in the database" do
      season1 = create(:season)
      season2 = create(:season)
      week1 = FactoryBot.create(:week, week_number: 1, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season: season1)
      week2 = FactoryBot.create(:week, week_number: 2, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season: season1)
      week1_2 = FactoryBot.create(:week, week_number: 1, start_date: DateTime.new(2015,8,5), end_date: DateTime.new(2015,8,8), deadline: DateTime.new(2015,8,7), season: season2)
      week2_2 = FactoryBot.create(:week, week_number: 2, start_date: DateTime.new(2015,8,12), end_date: DateTime.new(2015,8,18), deadline: DateTime.new(2015,8,14), season: season2)
      web_state = create(:web_state, week_id: week1_2.id, season_id: season2.id)
      week1_2.move_to_next_week!
      expect(web_state.reload.week_id).to eq(week2_2.id)
    end

    it "should autopick for a pool entry that had not picked" do
      @season = create(:season)
      @week16 = FactoryBot.create(:week, week_number: 16, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season: @season)
      @week17 = FactoryBot.create(:week, week_number: 17, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season: @season)
      @web_state = create(:web_state, week_id: @week16.id, season_id: @season.id)
      @team1 = FactoryBot.create(:nfl_team)
      @team2 = FactoryBot.create(:nfl_team)
      @monday_matchup = Matchup.create(game_time: DateTime.new(2017,8,14,15,00), week_id: @week16.id, home_team_id: @team1.id, away_team_id: @team2.id)

      @pool_entry_nopick1 = FactoryBot.create(:pool_entry, team_name: "Losers did not pick", season: @season)
      @pool_entry_knocked = FactoryBot.create(:pool_entry, team_name: "We dont matter", knocked_out: true, season: @season)
      @pool_entry_pick1 = FactoryBot.create(:pool_entry, season: @season)
      @pick1 = FactoryBot.create(:pick, pool_entry: @pool_entry_pick1, week: @week16, nfl_team: @monday_matchup.away_team, matchup: @monday_matchup)

      @week16.move_to_next_week!

      expect(Pick.where(auto_picked: true).count).to eq(1)
      expect(Pick.where(auto_picked: true).first.nfl_team).to eq(@team1)
      expect(Pick.where(auto_picked: true).first.pool_entry).to eq(@pool_entry_nopick1)
      expect(@web_state.reload.week_id).to eq(@week17.id)
    end
  end



  describe "#autopick_matchup_during_week" do

    before(:each) do
      @season = FactoryBot.create(:season)
      @week = FactoryBot.create(:week, week_number: 16, start_date: DateTime.new(2017,8,13), end_date: DateTime.new(2017,8,19), deadline: DateTime.new(2017,8,17), season: @season)
      @team1 = FactoryBot.create(:nfl_team)
      @team2 = FactoryBot.create(:nfl_team)
      @team3 = FactoryBot.create(:nfl_team)
      @team4 = FactoryBot.create(:nfl_team)
      @monday_matchup = Matchup.create(game_time: DateTime.new(2017,8,14,15,00), week_id: @week.id, home_team_id: @team1.id, away_team_id: @team2.id)
      @wednesday_matchup = Matchup.create(game_time: DateTime.new(2017,8,16,15,30), week_id: @week.id, home_team_id: @team3.id, away_team_id: @team4.id)
    end

    it "should return the monday matchup if only one monday game" do
      expect(Week.autopick_matchup_during_week(@week.id)).to eq(@monday_matchup)
    end

    it "should return the FIRST monday matchup if multiple monday games" do
      @team5 = FactoryBot.create(:nfl_team)
      @team6 = FactoryBot.create(:nfl_team)
      @monday_matchup2 = Matchup.create(game_time: DateTime.new(2017,8,14,15,45), week_id: @week.id, home_team_id: @team5.id, away_team_id: @team6.id)
      expect(Week.autopick_matchup_during_week(@week.id)).to eq(@monday_matchup)
    end
  end


end
