require 'spec_helper'

describe Matchup do

  it { should belong_to :week }
  it { should have_one :home_team }
  it { should have_one :away_team }

  # pending how we want to deal with winning_teams and complete
  it { should have_one :winning_team }

  context "matchup complete" do

    pending "should increase win and loss count by one if not a tie"

    pending "should increase loss count by two if a tie"

  end

end
