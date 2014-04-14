require 'spec_helper'

describe PoolEntry do

  it { should have_many :picks }
  it { should have_many :payments }

  it { should validate_uniqueness_of :team_name }

end
