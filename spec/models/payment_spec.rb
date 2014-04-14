require 'spec_helper'

describe Payment do

  it { should validate_presence_of :amount }

end
