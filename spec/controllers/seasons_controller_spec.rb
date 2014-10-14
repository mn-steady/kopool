require 'spec_helper'

describe SeasonsController do

	describe "GET new" do
		it_behaves_like "requires sign in" do
			let(:action) { get :new }
		end

		it "sets the @season variable" do
			@user = create(:user)
			sign_in :user, @user
			get :new
			expect(assigns(:season)).to be_instance_of(Season)
		end
	end

	describe "GET season_summary" do
		before do
			@user1 = create(:user)
			@user2 = create(:user)
			@user3 = create(:user)
			@user4 = create(:user)
			sign_in @user1

			@season = Season.create(year: 2014, name: "2014 Season", entry_fee: 50)
			@week1 = Week.create(season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))
			@week2 = Week.create(season: @season, week_number: 2, start_date: DateTime.new(2014, 8, 12), deadline: DateTime.new(2014, 8, 15), end_date: DateTime.new(2014, 8, 18))
			@week3 = Week.create(season: @season, week_number: 3, start_date: DateTime.new(2014, 8, 19), deadline: DateTime.new(2014, 8, 22), end_date: DateTime.new(2014, 8, 25))
			@week4 = Week.create(season: @season, week_number: 4, start_date: DateTime.new(2014, 8, 26), deadline: DateTime.new(2014, 8, 29), end_date: DateTime.new(2014, 9, 1))
			
			@web_state = create(:web_state, week_id: @week4.id)

			@pool_entry1 = PoolEntry.create(user: @user1, team_name: "User 1 Team One", paid: true, season_id: @season.id)
			@pool_entry2 = PoolEntry.create(user: @user1, team_name: "User 1 Team Two", paid: true, season_id: @season.id)
			@pool_entry3 = PoolEntry.create(user: @user1, team_name: "User 1 Team Three", paid: true, season_id: @season.id)
			@pool_entry4 = PoolEntry.create(user: @user2, team_name: "User 2 Team One", paid: true, season_id: @season.id)
			@pool_entry5 = PoolEntry.create(user: @user2, team_name: "User 2 Team Two", paid: true, season_id: @season.id)
			@pool_entry6 = PoolEntry.create(user: @user2, team_name: "User 2 Team Three", paid: true, season_id: @season.id)
			@pool_entry7 = PoolEntry.create(user: @user3, team_name: "User 3 Team One", paid: true, season_id: @season.id)
			@pool_entry8 = PoolEntry.create(user: @user3, team_name: "User 3 Team Two", paid: true, season_id: @season.id)
			@pool_entry9 = PoolEntry.create(user: @user3, team_name: "User 3 Team Three", paid: true, season_id: @season.id)
			@pool_entry10 = PoolEntry.create(user: @user4, team_name: "User 4 Team One", paid: true, season_id: @season.id)
			@pool_entry11 = PoolEntry.create(user: @user4, team_name: "User 4 Team Two", paid: true, season_id: @season.id)
			@pool_entry12 = PoolEntry.create(user: @user4, team_name: "User 4 Team Three", paid: true, season_id: @season.id)

			@broncos = NflTeam.create(name: "Denver Broncos", conference: "NFC", division: "West")
			@vikings = NflTeam.create(name: "Minnesota Vikings", conference: "NFC", division: "North")
			@packers = NflTeam.create(name: "Green Bay Packers", conference: "NFC", division: "North")
			@lions = NflTeam.create(name: "Detroit Lions", conference: "NFC", division: "North")
			@chargers = NflTeam.create(name: "San Diego Chargers", conference: "AFC", division: "West")
			@steelers = NflTeam.create(name: "Pittsburg Steelers", conference: "AFC", division: "East")

			@matchup1_1 = Matchup.create(week_id: @week1.id, home_team: @broncos, away_team: @vikings, game_time: DateTime.new(2014,8,10,11))
			@matchup1_2 = Matchup.create(week_id: @week1.id, home_team: @packers, away_team: @lions, game_time: DateTime.new(2014,8,10,11))
			@matchup1_3 = Matchup.create(week_id: @week1.id, home_team: @chargers, away_team: @steelers, game_time: DateTime.new(2014,8,10,11))
			@matchup2_1 = Matchup.create(week_id: @week2.id, home_team: @broncos, away_team: @vikings, game_time: DateTime.new(2014,8,17,11))
			@matchup2_2 = Matchup.create(week_id: @week2.id, home_team: @packers, away_team: @lions, game_time: DateTime.new(2014,8,17,11))
			@matchup2_3 = Matchup.create(week_id: @week2.id, home_team: @chargers, away_team: @steelers, game_time: DateTime.new(2014,8,17,11))
			@matchup3_1 = Matchup.create(week_id: @week3.id, home_team: @broncos, away_team: @vikings, game_time: DateTime.new(2014,8,24,11))
			@matchup3_2 = Matchup.create(week_id: @week3.id, home_team: @packers, away_team: @lions, game_time: DateTime.new(2014,8,24,11))
			@matchup3_3 = Matchup.create(week_id: @week3.id, home_team: @chargers, away_team: @steelers, game_time: DateTime.new(2014,8,24,11))
			@matchup4_1 = Matchup.create(week_id: @week4.id, home_team: @broncos, away_team: @vikings, game_time: DateTime.new(2014,8,31,11))
			@matchup4_2 = Matchup.create(week_id: @week4.id, home_team: @packers, away_team: @lions, game_time: DateTime.new(2014,8,31,11))
			@matchup4_3 = Matchup.create(week_id: @week4.id, home_team: @chargers, away_team: @steelers, game_time: DateTime.new(2014,8,31,11))
		end

	end

	describe "POST create" do
		it_behaves_like "requires sign in" do
			let(:action) { post :create, season: attributes_for(:season) }
		end

		context "with valid input" do
			before do
				@user = create(:user)
				sign_in :user, @user
			end

			it "saves a new season" do
				@season = attributes_for(:season)
				post :create, season: @season
				expect(Season.count).to eq(1)
			end

			it "redirects to the season show page" do
				@season = attributes_for(:season)
				post :create, season: @season
				expect(response).to redirect_to season_path(Season.first)
			end

			it "sets a flash success message" do
				@season = attributes_for(:season)
				post :create, season: @season
				expect(flash[:success]).to be_present
			end
		end

		context "with invalid input" do

			before do
				@user = create(:user)
				sign_in :user, @user
			end

			it "does not save the season" do
				post :create, season: { name: "Test Season" }
				expect(Season.count).to eq(0)
			end

			it "renders the new template" do
				post :create, season: { name: "Test Season" }
				expect(response).to render_template :new
			end

			it "sets the flash danger method" do
				post :create, season: { name: "Test Season" }
				expect(flash[:danger]).to be_present
			end
		end
	end
end