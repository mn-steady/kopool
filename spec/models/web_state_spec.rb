require 'spec_helper'

describe WebState do

  it { should belong_to :current_week }

  it "does not allow you to have more than 1 WebState record" do
    season = FactoryGirl.create(:season)
    week_1 = FactoryGirl.create(:week, season: season)
    week_2 = FactoryGirl.create(:week, season: season)

    ws = WebState.new()
    ws.current_week = week_1
    ws.save!
    expect(WebState.count).to eq(1)

    ws_nogo = WebState.new()
    ws.current_week = week_2
    ws.save!
    expect(WebState.count).to eq(1)
  end

end
