require 'spec_helper'

describe Week do

  it { should have_many :matchups }
  it { should belong_to :season }

  it { should validate_presence_of :week_number }
  it { should validate_presence_of :start_date }
  it { should validate_presence_of :end_date }
  it { should validate_presence_of :deadline }

  pending "Add more!"
end
