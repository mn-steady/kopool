require 'spec_helper'

describe Season do

  it { should have_many :weeks }

  it { should validate_presence_of :entry_fee }
  it { should validate_presence_of :year }
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).scoped_to(:year)}

  pending "Add more tests!!!"
end
