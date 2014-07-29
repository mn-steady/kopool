require 'spec_helper'

describe Week do

  it { should have_many :matchups }
  it { should belong_to :season }

  it { should validate_presence_of :week_number }
  it { should validate_presence_of :start_date }
  it { should validate_presence_of :end_date }
  it { should validate_presence_of :deadline }

  describe "#week_number unique in season" do
    it "should not allow you to save a dup week_number in the same season" do
      season = create(:season)
      week1 = Week.create(week_number: 5, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season: season)
      week1.save!
      week2 = Week.create(week_number: 5, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season: season)
      expect {
        week2.save!
      }.to raise_error ActiveRecord::RecordInvalid
    end
    it "should allow you to save two weeks with dup week number in different season" do
      season = create(:season)
      week1 = Week.create(week_number: 5, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season: season)
      week1.save!
      season_2 = create(:season, year: season.year+1)
      week2 = Week.create(week_number: 5, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season_id: season_2.id)
      expect {
        week2.save!
      }.not_to raise_error
    end
  end

  describe "#close_week_for_picks" do
  	it "should set open_for_picks for the passed in week to false" do
  		season = create(:season)
  		week1 = Week.create(week_number: 1, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season: season)
  		#week2 = Week.create(week_number: 2, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season_id: season.id)
  		week1.close_week_for_picks!

      findit = Week.where(week_number: 1).first
  		expect(findit.open_for_picks).to eq(false)
  	end
  	it "should not set open_for_picks for other weeks to false" do
  		season = create(:season)
  		week1 = Week.create(week_number: 1, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season: season)
  		week2 = Week.create(week_number: 2, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season: season)
  		week1.close_week_for_picks!
  		expect(week2.open_for_picks).to eq(true)
  	end
  end

  describe "#move_to_next_week" do

    it "should not advance the week at the last week of the season" do
      season = create(:season)
      week16 = Week.create(week_number: 16, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season: season)
      week17 = Week.create(week_number: 17, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season: season)
      web_state = create(:web_state, week_id: week17.id)
      week17.move_to_next_week!
      expect(web_state.reload.week_id).to eq(week17.id)
    end

    it "should affect only the proper season's week if multiple seasons are in the database" do
      season1 = create(:season)
      season2 = create(:season)
      week1 = Week.create(week_number: 1, start_date: DateTime.new(2014,8,5), end_date: DateTime.new(2014,8,8), deadline: DateTime.new(2014,8,7), season: season1)
      week2 = Week.create(week_number: 2, start_date: DateTime.new(2014,8,12), end_date: DateTime.new(2014,8,18), deadline: DateTime.new(2014,8,14), season: season1)
      week1_2 = Week.create(week_number: 1, start_date: DateTime.new(2015,8,5), end_date: DateTime.new(2015,8,8), deadline: DateTime.new(2015,8,7), season: season2)
      week2_2 = Week.create(week_number: 2, start_date: DateTime.new(2015,8,12), end_date: DateTime.new(2015,8,18), deadline: DateTime.new(2015,8,14), season: season2)
      web_state = create(:web_state, week_id: week1_2.id)
      week1_2.move_to_next_week!
      expect(web_state.reload.week_id).to eq(week2_2.id)
    end
  end
end
