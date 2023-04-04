require 'spec_helper'

describe SeasonsController do

	describe "GET new" do
		it_behaves_like "requires sign in" do
			let(:action) { get :new }
		end

		it "sets the @season variable" do
			@user = create(:user)
			sign_in(@user, scope: :user)
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
			
			@web_state = create(:web_state, week_id: @week4.id, season_id: @season.id)

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

			# Week 1 winners: Broncos, Packers, Chargers
			# Week 2 winners: Vikings, Lions, Steelers
			# Week 3 winners: Broncos, Packers, Chargers
			# Week 4 winners: Vikings, Lions, Steelers

			# User 1 will lose 1 entry each in weeks 1, 2, and 3
			# User 2 will lose 2 entries in week 1 and the third in week 2
			# User 3 will lose 1 entry each in weeks 2 and 3, with 1 remaining
			# User 4 will lose 1 entry in week 4, with 2 remaining

			@pick1_1 = Pick.create(pool_entry_id: @pool_entry1.id, week_id: @week1.id, team_id: @vikings.id, matchup_id: @matchup1_1.id)
			@pick1_2 = Pick.create(pool_entry_id: @pool_entry2.id, week_id: @week1.id, team_id: @packers.id, matchup_id: @matchup1_2.id)
			@pick1_3 = Pick.create(pool_entry_id: @pool_entry3.id, week_id: @week1.id, team_id: @chargers.id, matchup_id: @matchup1_3.id)
			@pick1_4 = Pick.create(pool_entry_id: @pool_entry4.id, week_id: @week1.id, team_id: @vikings.id, matchup_id: @matchup1_1.id)
			@pick1_5 = Pick.create(pool_entry_id: @pool_entry5.id, week_id: @week1.id, team_id: @lions.id, matchup_id: @matchup1_2.id)
			@pick1_6 = Pick.create(pool_entry_id: @pool_entry6.id, week_id: @week1.id, team_id: @chargers.id, matchup_id: @matchup1_3.id)
			@pick1_7 = Pick.create(pool_entry_id: @pool_entry7.id, week_id: @week1.id, team_id: @broncos.id, matchup_id: @matchup1_1.id)
			@pick1_8 = Pick.create(pool_entry_id: @pool_entry8.id, week_id: @week1.id, team_id: @packers.id, matchup_id: @matchup1_2.id)
			@pick1_9 = Pick.create(pool_entry_id: @pool_entry9.id, week_id: @week1.id, team_id: @chargers.id, matchup_id: @matchup1_3.id)
			@pick1_10 = Pick.create(pool_entry_id: @pool_entry10.id, week_id: @week1.id, team_id: @broncos.id, matchup_id: @matchup1_1.id)
			@pick1_11 = Pick.create(pool_entry_id: @pool_entry11.id, week_id: @week1.id, team_id: @packers.id, matchup_id: @matchup1_2.id)
			@pick1_12 = Pick.create(pool_entry_id: @pool_entry12.id, week_id: @week1.id, team_id: @chargers.id, matchup_id: @matchup1_3.id)

			# Handle Week 1 Outcomes

			@matchup1_1.update_attributes(winning_team_id: @broncos.id)
			@matchup1_2.update_attributes(winning_team_id: @packers.id)
			@matchup1_3.update_attributes(winning_team_id: @chargers.id)
			Matchup.handle_matchup_outcome!(@matchup1_1.id)
			Matchup.handle_matchup_outcome!(@matchup1_2.id)
			Matchup.handle_matchup_outcome!(@matchup1_3.id)

			# Week 2 Picks

			@pick2_2 = Pick.create(pool_entry_id: @pool_entry2.id, week_id: @week2.id, team_id: @packers.id, matchup_id: @matchup2_2.id)
			@pick2_3 = Pick.create(pool_entry_id: @pool_entry3.id, week_id: @week2.id, team_id: @steelers.id, matchup_id: @matchup2_3.id)
			@pick2_6 = Pick.create(pool_entry_id: @pool_entry6.id, week_id: @week2.id, team_id: @chargers.id, matchup_id: @matchup2_3.id)
			@pick2_7 = Pick.create(pool_entry_id: @pool_entry7.id, week_id: @week2.id, team_id: @broncos.id, matchup_id: @matchup2_1.id)
			@pick2_8 = Pick.create(pool_entry_id: @pool_entry8.id, week_id: @week2.id, team_id: @lions.id, matchup_id: @matchup2_2.id)
			@pick2_9 = Pick.create(pool_entry_id: @pool_entry9.id, week_id: @week2.id, team_id: @steelers.id, matchup_id: @matchup2_3.id)
			@pick2_10 = Pick.create(pool_entry_id: @pool_entry10.id, week_id: @week2.id, team_id: @vikings.id, matchup_id: @matchup2_1.id)
			@pick2_11 = Pick.create(pool_entry_id: @pool_entry11.id, week_id: @week2.id, team_id: @lions.id, matchup_id: @matchup2_2.id)
			@pick2_12 = Pick.create(pool_entry_id: @pool_entry12.id, week_id: @week2.id, team_id: @steelers.id, matchup_id: @matchup2_3.id)

			# Handle Week 2 Outcomes

			@matchup2_1.update_attributes(winning_team_id: @vikings.id)
			@matchup2_2.update_attributes(winning_team_id: @lions.id)
			@matchup2_3.update_attributes(winning_team_id: @steelers.id)
			Matchup.handle_matchup_outcome!(@matchup2_1.id)
			Matchup.handle_matchup_outcome!(@matchup2_2.id)
			Matchup.handle_matchup_outcome!(@matchup2_3.id)

			# Week 3 Picks

			@pick3_3 = Pick.create(pool_entry_id: @pool_entry3.id, week_id: @week3.id, team_id: @steelers.id, matchup_id: @matchup3_3.id)
			@pick3_8 = Pick.create(pool_entry_id: @pool_entry8.id, week_id: @week3.id, team_id: @lions.id, matchup_id: @matchup3_2.id)
			@pick3_9 = Pick.create(pool_entry_id: @pool_entry9.id, week_id: @week3.id, team_id: @chargers.id, matchup_id: @matchup3_3.id)
			@pick3_10 = Pick.create(pool_entry_id: @pool_entry10.id, week_id: @week3.id, team_id: @broncos.id, matchup_id: @matchup3_1.id)
			@pick3_11 = Pick.create(pool_entry_id: @pool_entry11.id, week_id: @week3.id, team_id: @packers.id, matchup_id: @matchup3_2.id)
			@pick3_12 = Pick.create(pool_entry_id: @pool_entry12.id, week_id: @week3.id, team_id: @chargers.id, matchup_id: @matchup3_3.id)	

			# Handle Week 3 Outcomes

			@matchup3_1.update_attributes(winning_team_id: @broncos.id)
			@matchup3_2.update_attributes(winning_team_id: @packers.id)
			@matchup3_3.update_attributes(winning_team_id: @chargers.id)
			Matchup.handle_matchup_outcome!(@matchup3_1.id)
			Matchup.handle_matchup_outcome!(@matchup3_2.id)
			Matchup.handle_matchup_outcome!(@matchup3_3.id)

			# Week 4 Picks

			@pick4_9 = Pick.create(pool_entry_id: @pool_entry9.id, week_id: @week4.id, team_id: @steelers.id, matchup_id: @matchup4_3.id)
			@pick4_10 = Pick.create(pool_entry_id: @pool_entry10.id, week_id: @week4.id, team_id: @broncos.id, matchup_id: @matchup4_1.id)
			@pick4_11 = Pick.create(pool_entry_id: @pool_entry11.id, week_id: @week4.id, team_id: @lions.id, matchup_id: @matchup4_2.id)
			@pick4_12 = Pick.create(pool_entry_id: @pool_entry12.id, week_id: @week4.id, team_id: @steelers.id, matchup_id: @matchup4_3.id)	

			# Handle Week 4 Outcomes

			@matchup4_1.update_attributes(winning_team_id: @vikings.id)
			@matchup4_2.update_attributes(winning_team_id: @lions.id)
			@matchup4_3.update_attributes(winning_team_id: @steelers.id)
			Matchup.handle_matchup_outcome!(@matchup4_1.id)
			Matchup.handle_matchup_outcome!(@matchup4_2.id)
			Matchup.handle_matchup_outcome!(@matchup4_3.id)

		end

		it "returns 4 weeks worth of values" do
			get :season_summary, params: { season_id: @season.id, format: :json }

			expect(response.status).to eq(Rack::Utils.status_code(:ok))
			returned = JSON.parse(response.body)

			expect(returned.count).to eq(4)
		end

		it "retuns the correct week numbers for each week" do
			get :season_summary, params: { season_id: @season.id, format: :json }

			expect(response.status).to eq(Rack::Utils.status_code(:ok))
			returned = JSON.parse(response.body)

			expect(returned[0]["x"]).to eq("1")
			expect(returned[1]["x"]).to eq("2")
			expect(returned[2]["x"]).to eq("3")
			expect(returned[3]["x"]).to eq("4")
		end

		it "retuns the correct remaining pool entry counts for each week" do
			get :season_summary, params: { season_id: @season.id, format: :json }

			expect(response.status).to eq(Rack::Utils.status_code(:ok))
			returned = JSON.parse(response.body)

			expect(returned[0]["y"]).to eq([9])
			expect(returned[1]["y"]).to eq([6])
			expect(returned[2]["y"]).to eq([4])
			expect(returned[3]["y"]).to eq([3])
		end

	end

	describe 'GET season_entries_status' do
		before do
			@user1 = create(:user)
			@user2 = create(:user)
			@user3 = create(:user)
			@user4 = create(:user)
			sign_in @user1

			@season = Season.create(year: 2014, name: "2014 Season", entry_fee: 50)
			@season_2 = Season.create(year: 2015, name: "2015 Season", entry_fee: 50)
			@week1 = Week.create(season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))
			
			@web_state = create(:web_state, week_id: @week1.id, season_id: @season.id)

			@pool_entry1 = PoolEntry.create(user: @user1, team_name: "User 1 Team One", paid: true, season_id: @season.id)
			@pool_entry2 = PoolEntry.create(user: @user1, team_name: "User 1 Team Two", paid: true, season_id: @season.id)
			@pool_entry3 = PoolEntry.create(user: @user1, team_name: "User 1 Team Three", paid: true, season_id: @season.id)
			@pool_entry4 = PoolEntry.create(user: @user2, team_name: "User 2 Team One", paid: true, season_id: @season.id)
			@pool_entry5 = PoolEntry.create(user: @user2, team_name: "User 2 Team Two", paid: true, season_id: @season.id)
			@pool_entry6 = PoolEntry.create(user: @user2, team_name: "User 2 Team Three", paid: true, season_id: @season.id)
			@pool_entry7 = PoolEntry.create(user: @user3, team_name: "User 3 Team One", paid: true, season_id: @season.id)
			@pool_entry8 = PoolEntry.create(user: @user3, team_name: "User 3 Team Two", paid: true, season_id: @season.id, knocked_out: true)
			@pool_entry9 = PoolEntry.create(user: @user3, team_name: "User 3 Team Three", paid: true, season_id: @season.id, knocked_out: true)
			@pool_entry10 = PoolEntry.create(user: @user4, team_name: "User 4 Team One", paid: true, season_id: @season.id, knocked_out: true)
			@pool_entry11 = PoolEntry.create(user: @user4, team_name: "User 4 Team Two", paid: true, season_id: @season.id, knocked_out: true)
			@pool_entry12 = PoolEntry.create(user: @user4, team_name: "User 4 Team Three", paid: true, season_id: @season.id, knocked_out: true)

			@bad_entry_1 = PoolEntry.create(user: @user1, team_name: "User 1 Team One", paid: true, season_id: @season_2.id)
			@bad_entry_2 = PoolEntry.create(user: @user2, team_name: "User 2 Team One", paid: true, season_id: @season_2.id, knocked_out: true)
		end

		it 'returns the counts of knocked_out and non-knocked out users' do
			get :season_knockout_counts, params: { season_id: @season.id, format: :json }
			returned = JSON.parse(response.body)
			expect(returned['false']).to eql 7
			expect(returned['true']).to eql 5
		end
	end

	describe "POST create" do
		it_behaves_like "requires sign in" do
			let(:action) { post :create, params: { season: attributes_for(:season) } }
		end

		context "with valid input" do
			before do
				@user = create(:user)
				sign_in(@user, scope: :user)
			end

			it "saves a new season" do
				@season = attributes_for(:season)
				post :create, params: { season: @season }
				expect(Season.count).to eq(1)
			end

			it "redirects to the season show page" do
				@season = attributes_for(:season)
				post :create, params: { season: @season }
				expect(response).to redirect_to season_path(Season.first)
			end

			it "sets a flash success message" do
				@season = attributes_for(:season)
				post :create, params: { season: @season }
				expect(flash[:success]).to be_present
			end
		end

		context "with invalid input" do

			before do
				@user = create(:user)
				sign_in(@user, scope: :user)
			end

			it "does not save the season" do
				post :create, params: { season: { name: "Test Season" } }
				expect(Season.count).to eq(0)
			end

			it "renders the new template" do
				post :create, params: { season: { name: "Test Season" } }
				expect(response).to render_template :new
			end

			it "sets the flash danger method" do
				post :create, params: { season: { name: "Test Season" } }
				expect(flash[:danger]).to be_present
			end
		end
	end
end
