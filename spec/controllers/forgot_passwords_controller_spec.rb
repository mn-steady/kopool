require 'spec_helper'

describe ForgotPasswordsController do
	describe "POST create" do

		before(:each) do
      @regular_guy = create(:user)
  		request.env['devise.mapping'] = Devise.mappings[:user]
    end

		context "with existing email" do

			it "sends out an email to the email address" do
				post :create, params: { user_email: @regular_guy.email, format: :json }
				expect(ActionMailer::Base.deliveries.last.to).to eq([@regular_guy.email])
			end

		end

		context "with non-existent email" do

			it "doesn't send an email" do
				post :create, params: { user_email: 'foo@example.com', format: :json }
				expect(ActionMailer::Base.deliveries.count).to eq(1) # The welcome email is sent with user creation, so you still have 1 email
			end

		end
	end

	describe "PUT update" do

		before(:each) do
      @regular_guy = create(:user)
  		request.env['devise.mapping'] = Devise.mappings[:user]
    end

    context "with valid password" do
    	it "updates the password"
    end

    context "with invalid password" do
    	it "does not update the password"

    end
	end
end
