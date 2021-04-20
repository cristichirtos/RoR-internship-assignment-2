class Car
  attr_reader :id
  attr_accessor :required_time

  def initialize(id, required_time = nil)
    @id = id
    @required_time = required_time
  end

end
