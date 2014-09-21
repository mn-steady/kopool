require 'spec_helper'

describe NflTeam do
  it { should validate_presence_of :name }
  it { should validate_presence_of :conference }
  it { should validate_presence_of :division }

  it { should respond_to :logo_url_small }

end
