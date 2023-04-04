require 'spec_helper'

RSpec.describe Payment, type: :model do

  it { should validate_presence_of :amount }

end
