require 'spec_helper'

describe PoolEntry do

  it { should have_many :picks }
  it { should have_many :payments }
  it { should belong_to :user }

  it { should validate_uniqueness_of(:team_name).scoped_to(:season_id) }

end
