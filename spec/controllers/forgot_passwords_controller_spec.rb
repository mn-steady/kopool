require 'spec_helper'

describe ForgotPasswordsController do
	describe "POST create" do

		before(:each) do
      @regular_guy = create(:user)
    end

		context "with existing email" do

			it "sends out an email to the email address" do
				post :create, email: @regular_guy.email, format: :json
				expect(ActionMailer::Base.deliveries.last.to).to eq([@regular_guy.email])
			end

		end

		context "with non-existent email" do

			it "doesn't send an email" do
				post :create, email: 'foo@example.com', format: :json
				expect(ActionMailer::Base.deliveries.count).to eq(0)
			end

		end
	end
end