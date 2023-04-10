require 'spec_helper'

RSpec.describe Season, type: :model do

  it { should have_many :weeks }
  it { should have_many :pool_entries }

  it { should validate_presence_of :entry_fee }
  it { should validate_presence_of :year }
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).scoped_to(:year)}

  it { should respond_to :open_for_registration }

end
