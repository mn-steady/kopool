require 'spec_helper'

describe SeasonsController do
	pending "Admins can change the open/closed status of a season"
	pending "Non-admins cannot change the open/closed status of a season"

	describe "GET new" do
		it "requires a signed in user" do
			get :new
			expect(response).to redirect_to new_user_session_path
		end

		it "sets the @season variable" do
			@user = create(:user)
			sign_in :user, @user
			get :new
			expect(assigns(:season)).to be_instance_of(Season)
		end
	end
end