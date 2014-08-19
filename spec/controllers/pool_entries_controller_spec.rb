require 'spec_helper'

describe PoolEntriesController do

	describe "POST create" do

		before do
			@season = Season.create(year: 2014, name: "2014 Season", entry_fee: 50)
      @week = Week.create(season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))
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

			it "will not create a new pool entry after the first week" do
				@week.update_attributes(week_number: 2)
				post :create, user: @user, team_name: "Test Team", format: :json
				expect(response.status).to eq(Rack::Utils.status_code(:bad_request))
				expect(PoolEntry.count).to eq(0)
			end

		end
	end
end