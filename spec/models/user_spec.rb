require 'spec_helper'

describe User do
  it { should have_many :pool_entries }
  it { should belong_to :favorite_team }
  it { should validate_presence_of :email }
  it { should validate_uniqueness_of(:email).case_insensitive }
  it { should validate_presence_of :encrypted_password }

  pending "add some examples to (or delete) #{__FILE__}"
end
