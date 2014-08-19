require 'spec_helper'

describe User do
  it { should have_many :pool_entries }
  it { should belong_to :favorite_team }
  it { should validate_presence_of :email }
  it { should validate_uniqueness_of(:email).case_insensitive }
  it { should validate_presence_of :encrypted_password }
  it { should respond_to :admin  }

  context "New User" do

    before(:each) do
      @newuser = User.new()
    end

    it "should not be an admin" do
      expect(@newuser.admin).to eq(false)
    end
  end

end
