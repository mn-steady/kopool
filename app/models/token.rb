class Token

  attr_accessor :token
  attr_accessor :reload_predefined_data
  attr_accessor :user

  def read_attribute_for_serialization(attr)
    self.send(attr)
  end

end