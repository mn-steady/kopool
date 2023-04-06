module URI
  def self.escape url
    URI::Parser.new.escape url
  end
end
