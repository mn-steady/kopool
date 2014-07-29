require 'spec_helper'

describe NflTeamsController do

  describe "Update" do
     before(:each) do
      @admin = create(:admin)
      sign_in @admin

      @season = Season.create(year: 2014, name: "2014 Season", entry_fee: 50)
      @week = Week.create(season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))

      @broncos = NflTeam.create(name: "Denver Broncos", conference: "NFC", division: "West")
    end

    it "updates the NflTeam" do
      patch :update, id: @broncos.id, post: {name: "Colorado Broncos"}, format: :json
      expect(NflTeam.first.name).to eq("Colorado Broncos")
    end
  end

  describe "DELETE destroy" do

    before(:each) do
      @admin = create(:admin)
      sign_in @admin

      @season = Season.create(year: 2014, name: "2014 Season", entry_fee: 50)
      @week = Week.create(season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))

      @broncos = NflTeam.create(name: "Denver Broncos", conference: "NFC", division: "West")
    end

    it "deletes the NflTeam if you are an admin" do
      delete :destroy, id: @broncos.id, format: :json
      expect(NflTeam.all.count).to eq(0)
    end

    it "Will not delete the NflTeam if you are not an admin" do
      @regular_guy = create(:user)
      sign_in @regular_guy
      delete :destroy, id: @broncos.id, format: :json
      expect(NflTeam.all.count).to eq(1)
    end

  end

end