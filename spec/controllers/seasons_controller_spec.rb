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