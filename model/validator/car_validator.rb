class CarValidator
  ID_FORMAT = /^([A-Z]){2}([0-9]){2,3}([A-Z]){3}$/

  attr_reader :errors

  def initialize(car, time)
    @car = car
    @time = time
    @errors = []
  end

  def valid?
    validate_id
    validate_time
    errors.empty?
  end

  private

  def validate_id
    errors.push('Invalid car identification number.') unless @car.id.match(ID_FORMAT)
  end

  def validate_time
    errors.push('Required time cannot be before the current time.') unless @car.required_time.nil? || @car.required_time > @time
  end
end
