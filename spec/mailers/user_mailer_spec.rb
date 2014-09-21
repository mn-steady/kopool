require "spec_helper"

describe UserMailer do

  describe "new user email" do

    before do
      @user = create(:user)
    end

    context "we send new user email" do

      subject { UserMailer.welcome_email(@user) }

      it "should send a new  email" do
        expect(subject.subject).to eq('Welcome to the KOPool')
        Rails.logger.debug("EMAIL:\n#{subject.body}")
        expect(subject.body).to match("your username is: #{@user.email}")
        expect(subject.body).to match("Welcome to Testing Season KOPool")
      end

    end
  end
end
