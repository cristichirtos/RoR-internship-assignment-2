require 'time'
require_relative '../model/car_cleaner'
require_relative '../model/car'

class CarCleanerService

  ONE_HOUR_IN_SECONDS = 3600

  attr_reader :car_cleaner, :time

  def initialize(time)
    @car_cleaner = CarCleaner.new
    @time = time
  end

  def add_car(car)
    end_of_day = Time.parse(time.strftime("%Y-%m-%dT#{today_closing_hour}:00:00%z"))
    car.required_time = end_of_day if car.required_time.nil?
    position_in_queue = -1

    car_cleaner.queue.each do |car_in_queue|
      next unless car_in_queue.required_time.nil? || car_in_queue.required_time > car.required_time
      position_in_queue = car_cleaner.queue.index(car_in_queue)
      break
    end

    position_in_queue == -1 ? car_cleaner.queue.push(car) : car_cleaner.queue.insert(position_in_queue, car)
  end

  def simulate_service(number_of_hours)
    @actions = []

    number_of_hours.times do
      if is_open?
        @actions.push("[#{format_time}] Nothing significant happened...") unless handle_car_servicing
      else
        @actions.push("[#{format_time}] Car cleaning service is closed until tomorrow morning.")
      end

      @time += ONE_HOUR_IN_SECONDS
    end

    handle_car_servicing
    @actions.push("[#{format_time}] Moved forward in time by #{number_of_hours} hours.")
  end

  def pick_up_car(car_id)
    return false unless car_cleaner.cars_ready.has_key?(car_id.to_sym)

    car_cleaner.cars_ready.delete(car_id.to_sym)
    true
  end

  def time_ready(car)
    estimated_time = time + ONE_HOUR_IN_SECONDS * CarCleaner::CAR_CLEANING_TIME_IN_HOURS
    time_until_processing = (car_cleaner.queue.index(car) / CarCleaner::MAX_CARS_AT_ONCE) * CarCleaner::CAR_CLEANING_TIME_IN_HOURS

    until time_until_processing == 0
      time_until_processing -= 1 if is_open? estimated_time
      estimated_time += ONE_HOUR_IN_SECONDS
    end

    format_time(estimated_time)
  end

  def format_time(time_asked = time)
    time_asked.strftime("%d/%m/%Y %I:%M %p")
  end

  def show_queue
    string_queue = ""
    car_cleaner.queue.each { |car| string_queue += "#{car.id} "}
    string_queue
  end

  private

  def handle_car_servicing
    anything_happened = false
    car_cleaner.cars_in_process.each do |car, enter_time|

      if time - enter_time >= ONE_HOUR_IN_SECONDS * CarCleaner::CAR_CLEANING_TIME_IN_HOURS
        car_cleaner.cars_ready[car.id.to_sym] = car
        car_cleaner.cars_in_process.delete(car)

        @actions.push("[#{format_time}] Car #{car.id} done cleaning & ready for pick up!")
        anything_happened = true
      end
    end

    until car_cleaner.queue.empty? || car_cleaner.cars_in_process.size >= CarCleaner::MAX_CARS_AT_ONCE
      car = car_cleaner.queue.shift
      car_cleaner.cars_in_process[car] = time
      @actions.push("[#{format_time}] Car #{car.id} moved to start cleaning process.")
      anything_happened = true
    end

    anything_happened
  end

  def is_open?(time_asked = time)
    if time_asked.saturday?
      time_asked.hour.between?(CarCleaner::SATURDAY_OPENING_HOUR, CarCleaner::SATURDAY_CLOSING_HOUR)
    elsif time_asked.sunday?
      time_asked.hour.between?(CarCleaner::SUNDAY_OPENING_HOUR, CarCleaner::SUNDAY_CLOSING_HOUR)
    else
      time_asked.hour.between?(CarCleaner::WEEKDAY_OPENING_HOUR, CarCleaner::WEEKDAY_CLOSING_HOUR)
    end
  end

  def today_closing_hour
    return CarCleaner::SATURDAY_CLOSING_HOUR if @time.saturday?

    return CarCleaner::SUNDAY_CLOSING_HOUR if @time.sunday?

    CarCleaner::WEEKDAY_CLOSING_HOUR
  end
end
