require 'spec_helper'

describe Season do

  it { should have_many :weeks }

  it { should validate_presence_of :entry_fee }

  pending "uniqueness of name within year"
  #it { should validate_uniqueness_of :name }

  pending "Add more tests!!!"
end
