require 'spec_helper'

describe SeasonsController do
	pending "Admins can change the open/closed status of a season"
	pending "Non-admins cannot change the open/closed status of a season"

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

			it "sets a flash success message"
		end

		context "with invalid input" do
			it "does not save the season"
			it "renders the new template"
			it "sets the flash danger method"
		end
	end
end