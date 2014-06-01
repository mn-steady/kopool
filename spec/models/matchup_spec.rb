require 'spec_helper'

describe Matchup do

  it { should belong_to :week }
  it { should belong_to :home_team }
  it { should belong_to :away_team }

  it { should validate_presence_of :week }
  it { should validate_presence_of :home_team }
  it { should validate_presence_of :away_team }

  context "matchup complete" do

    pending "should increase win and loss count by one if not a tie"

    pending "should increase loss count by two if a tie"

    pending "should have one winning team if not a tie"

  end

end
