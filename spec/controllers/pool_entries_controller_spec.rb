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
end