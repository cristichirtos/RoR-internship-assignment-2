class CarCleaner  
  MAX_CARS_AT_ONCE = 2
  CAR_CLEANING_TIME_IN_HOURS = 2
  WEEKDAY_OPENING_HOUR = 8
  WEEKDAY_CLOSING_HOUR = 18
  SATURDAY_OPENING_HOUR = 9
  SATURDAY_CLOSING_HOUR = 17
  SUNDAY_OPENING_HOUR = 11
  SUNDAY_CLOSING_HOUR = 16

  attr_accessor :queue, :cars_ready, :cars_in_process

  def initialize(queue = [])
    @queue = []
    @cars_ready = {}
    @cars_in_process = {}
  end
  
end
