require 'spec_helper'

describe PoolEntry do

  it { should have_many :picks }
  it { should have_many :payments }
  it { should belong_to :user }

  it { should validate_uniqueness_of(:team_name).scoped_to(:season_id) }

  describe "#needs_autopicking" do

    before(:each) do
      @season = FactoryGirl.create(:season)
      @week = FactoryGirl.create(:week, season: @season)
      @matchup = FactoryGirl.create(:matchup, week_id: @week.id)
      @pool_entry_nopick1 = FactoryGirl.create(:pool_entry, team_name: "Losers did not pick", season: @season)
      @pool_entry_nopick2 = FactoryGirl.create(:pool_entry, team_name: "Losers did not pick either", season: @season)
      @pool_entry_knocked = FactoryGirl.create(:pool_entry, team_name: "We dont matter", knocked_out: true, season: @season)
      @pool_entry_pick1 = FactoryGirl.create(:pool_entry, season: @season)
      @pick1 = FactoryGirl.create(:pick, pool_entry: @pool_entry_pick1, week: @week, nfl_team: @matchup.away_team, matchup: @matchup)
      @pool_entry_pick2 = FactoryGirl.create(:pool_entry, season: @season)
      @pick2 = FactoryGirl.create(:pick, pool_entry: @pool_entry_pick2, week: @week, nfl_team: @matchup.away_team, matchup: @matchup)

      # some irrelevant data to be sure we don't have totally bogus query
      @diff_season = FactoryGirl.create(:season)
      @week2 = FactoryGirl.create(:week, season: @diff_season)
      @matchup2 = FactoryGirl.create(:matchup, week_id: @week2.id)
      @i_pool_entry_nopick1 = FactoryGirl.create(:pool_entry, team_name: "Wrong week no pick", season: @diff_season)
      @i_pool_entry_pick1 = FactoryGirl.create(:pool_entry, season: @diff_season)
      @i_pick1 = FactoryGirl.create(:pick, pool_entry: @i_pool_entry_pick1, week: @week2, nfl_team: @matchup2.away_team, matchup: @matchup2)
    end

    it "should return any not KO'd PoolEntry with no Pick this season this week" do
      these_need_autopicking = PoolEntry.needs_autopicking(@week)
      expect(these_need_autopicking.count).to eq(2)
      expect(these_need_autopicking.first).to eq(@pool_entry_nopick1)
      expect(these_need_autopicking.last).to eq(@pool_entry_nopick2)
    end

  end

end
