require 'spec_helper'

describe Pick do

  it { should belong_to :week }
  it { should belong_to :nfl_team }

  it { should validate_presence_of :team_id }

  pending "should not allow more than one pick per pool_entry_per_week"

  pending "should allow more than one pick for two different pool entries"

  pending "should not save pick if pool_entry is not paid"

  pending "should be locked_in automatically at the week deadline"

  pending "should record auto_pcked when auto-picked"

  pending "cannot be changed if locked in"

end
