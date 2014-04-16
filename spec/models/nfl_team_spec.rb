require 'spec_helper'

describe NflTeam do
  it { should validate_presence_of :name }
  it { should validate_presence_of :conference }
  it { should validate_presence_of :division }

  pending "add some examples to (or delete) #{__FILE__}"
end
