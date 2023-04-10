require 'spec_helper'

describe NflTeamsController do

  describe "index" do
     before(:each) do
      @regular_guy = create(:user)
      sign_in @regular_guy

      @season = Season.create(year: 2014, name: "2014 Season", entry_fee: 50)
      @week = FactoryBot.create(:week, season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))

      @broncos = NflTeam.create(name: "Denver Broncos", conference: "NFC", division: "West")
      @vikings = NflTeam.create(name: "Minnesota Vikings", conference: "NFC", division: "West")
    end

    it "give anyone the index" do
      get :index, format: :json
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).length).to eq(NflTeam.count)
    end
  end

  describe "show" do
     before(:each) do
      @admin = create(:admin)
      sign_in @admin

      @season = Season.create(year: 2014, name: "2014 Season", entry_fee: 50)
      @week = FactoryBot.create(:week, season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))

      @broncos = NflTeam.create(name: "Denver Broncos", conference: "NFC", division: "West")
      @vikings = NflTeam.create(name: "Minnesota Vikings", conference: "NFC", division: "West")
    end

    it "show an admin the correct team" do
      put :show, params: { id: @vikings.id, format: :json }
      expect(JSON.parse(response.body)['name']).to eq("Minnesota Vikings")
    end

    it "will not show a non-admin the correct team" do
      @regular_guy = create(:user)
      sign_in @regular_guy
      put :show, params: { id: @vikings.id, format: :json }
      expect(response.status).to eq(Rack::Utils.status_code(:unauthorized))
    end

  end

  describe "update" do
     before(:each) do
      @admin = create(:admin)
      sign_in @admin

      @season = Season.create(year: 2014, name: "2014 Season", entry_fee: 50)
      @week = FactoryBot.create(:week, season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))

      @broncos = NflTeam.create(name: "Denver Broncos", conference: "NFC", division: "West")
    end

    it "updates the NflTeam if you are an admin" do
      put :update, params: { id: @broncos.id, nfl_team: {name: "Colorado Broncos"} }, format: :json
      expect(NflTeam.find(@broncos.id).name).to eq("Colorado Broncos")
    end

    it "will not update the NflTeam if you are not an admin" do
      @regular_guy = create(:user)
      sign_in @regular_guy
      put :update, params: { id: @broncos.id, nfl_team: {name: "Colorado Broncos"} }, format: :json
      expect(NflTeam.find(@broncos.id).name).to eq("Denver Broncos")
    end
  end

  describe "DELETE destroy" do

    before(:each) do
      @admin = create(:admin)
      sign_in @admin

      @season = Season.create(year: 2014, name: "2014 Season", entry_fee: 50)
      @week = FactoryBot.create(:week, season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))

      @broncos = NflTeam.create(name: "Denver Broncos", conference: "NFC", division: "West")
    end

    it "deletes the NflTeam if you are an admin" do
      expect { delete :destroy, params: { id: @broncos.id }, format: :json }.to change { NflTeam.count }.by(-1)
      expect(response).to have_http_status(:ok)
      expect(NflTeam.find_by_id(@broncos.id)).to be_nil
    end

    it "Will not delete the NflTeam if you are not an admin" do
      @regular_guy = create(:user)
      sign_in @regular_guy
      expect { delete :destroy, params: { id: @broncos.id, format: :json } }.not_to change { NflTeam.count }
      expect(response).to have_http_status(:unauthorized)
      expect(NflTeam.find_by_id(@broncos.id)).not_to be_nil
    end

  end

  describe "create" do
     before(:each) do
      @admin = create(:admin)
      sign_in @admin

      @season = Season.create(year: 2014, name: "2014 Season", entry_fee: 50)
      @week = FactoryBot.create(:week, season: @season, week_number: 1, start_date: DateTime.new(2014, 8, 5), deadline: DateTime.new(2014, 8, 8), end_date: DateTime.new(2014, 8, 11))

      @broncos = NflTeam.create(name: "Denver Broncos", conference: "NFC", division: "West")

      @new_team = {name: "Minnesota Vikings", conference: "NFC", division: "Central"}

    end

    it "creates an NflTeam if you are an admin" do
      post :create, params: { nfl_team: @new_team, format: :json }
      expect(response.status).to eq(Rack::Utils.status_code(:ok))
      expect(NflTeam.last.name).to eq("Minnesota Vikings")
    end

    it "Will not update the NflTeam if you are not an admin" do
      @regular_guy = create(:user)
      sign_in @regular_guy

      post :create, params: { nfl_team: @new_team, format: :json }

      expect(response.status).to eq(Rack::Utils.status_code(:unauthorized))
      expect(NflTeam.last.name).not_to eq("Minnesota Vikings")
    end
  end

end
