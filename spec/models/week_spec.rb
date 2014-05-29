require 'spec_helper'

describe Week do

  it { should have_many :matchups }
  it { should belong_to :season }

  it { should validate_presence_of :week_number }
  it { should validate_presence_of :start_date }
  it { should validate_presence_of :end_date }
  it { should validate_presence_of :deadline }

  pending "Add more Week tests"

  describe "#close_week_for_picks" do
  	it "should set open_for_picks for the passed in week to false" do
  		season = create(:season)
  		week1 = Week.create(week_number: 1, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season_id: season.id)
  		#week2 = Week.create(week_number: 2, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season_id: season.id)
  		week1.close_week_for_picks
  		expect(week1.open_for_picks).to eq(false)
  	end
  	it "should not set open_for_picks for other weeks to false" do
  		season = create(:season)
  		week1 = Week.create(week_number: 1, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season_id: season.id)
  		week2 = Week.create(week_number: 2, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season_id: season.id)
  		week1.close_week_for_picks
  		expect(week2.open_for_picks).to eq(true)
  	end
  end
end
