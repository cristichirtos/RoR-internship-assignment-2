require 'time'

class Car
  attr_reader :id
  attr_accessor :required_time

  def initialize(id, required_time = nil)
    @id = id
    @required_time = required_time
  end

  def to_s
    @id
  end

  def to_sym
    @id.to_sym
  end
end

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
    @errors.empty?
  end

  private

  def validate_id
    @errors.push("Invalid car identification number.") unless @car.to_s.match(ID_FORMAT)
  end

  def validate_time
    @errors.push("Required time cannot be before the current time.") unless @car.required_time.nil? || @car.required_time > @time
  end
end


class CarCleaningService
  MAX_CARS_AT_ONCE = 2
  CAR_CLEANING_TIME_IN_HOURS = 2
  ONE_HOUR_IN_SECONDS = 3600
  WEEKDAY_OPENING_HOUR = 8
  WEEKDAY_CLOSING_HOUR = 18
  SATURDAY_OPENING_HOUR = 9
  SATURDAY_CLOSING_HOUR = 17
  SUNDAY_OPENING_HOUR = 11
  SUNDAY_CLOSING_HOUR = 16

  attr_reader :time, :queue

  def initialize()
    @queue = []
    @cars_ready = {}
    @cars_in_process = {}
    @time = Time.parse(Time.now.strftime("%Y-%m-%dT08:00:00%z")) # the initial time of the simulation is the current day at 8:00
  end

  public

  def add_car(car)
    # if the client did not specify the time they need the car, I consider it to be the end of the day
    car.required_time = Time.parse(@time.strftime("%Y-%m-%dT#{today_closing_hour}:00:00%z")) if car.required_time.nil?
    position_in_queue = -1
    @queue.each { |car_in_queue|
      next unless car_in_queue.required_time.nil? || car_in_queue.required_time > car.required_time
      position_in_queue = @queue.index(car_in_queue)
      break
    }
    position_in_queue == -1 ? @queue.push(car) : @queue.insert(position_in_queue, car)
    puts "[#{format_time}] Car #{car.to_s} queued for servicing. Estimated time when car will be ready: #{format_time(time_ready(car))}."
  end

  def simulate_service(number_of_hours)
    number_of_hours.times {
      if is_open?
        puts "[#{format_time}] Nothing significant happened..." unless handle_car_servicing 
      else
        puts "[#{format_time}] Car cleaning service is closed until tomorrow morning."
      end
      @time += ONE_HOUR_IN_SECONDS
    }
    handle_car_servicing
    puts "[#{format_time}] Moved forward in time by #{number_of_hours} hours."
  end

  def pick_up_car(car)
    if @cars_ready.has_key?(car.to_sym)
      @cars_ready.delete(car.to_sym)
      puts "[#{format_time}] Car #{car} picked up successfuly!"
    else
      puts "[#{format_time}] Car #{car} is not ready for pick up!"
    end
  end

  private

  def handle_car_servicing
    anything_happened = false
    @cars_in_process.each { |car, enter_time|
      if @time - enter_time >= CAR_CLEANING_TIME_IN_HOURS * ONE_HOUR_IN_SECONDS
        @cars_ready[car.to_sym] = car
        @cars_in_process.delete(car)
        puts "[#{format_time}] Car #{car.to_s} done cleaning & ready for pick up!"
        anything_happened = true
      end
    }

    until @queue.empty? || @cars_in_process.size >= MAX_CARS_AT_ONCE
      car = @queue.shift
      @cars_in_process[car] = @time
      puts "[#{format_time}] Car #{car.to_s} moved to start cleaning process."
      anything_happened = true
    end

    return anything_happened
  end

  def time_ready(car)
    estimated_time = @time + CAR_CLEANING_TIME_IN_HOURS * ONE_HOUR_IN_SECONDS
    time_until_processing = (@queue.index(car) / MAX_CARS_AT_ONCE) * CAR_CLEANING_TIME_IN_HOURS
    until time_until_processing == 0
      time_until_processing -= 1 if is_open? estimated_time
      estimated_time += ONE_HOUR_IN_SECONDS
    end

    return estimated_time
  end

  def is_open?(time_asked = @time)
    if time_asked.saturday?
      time_asked.hour.between?(SATURDAY_OPENING_HOUR, SATURDAY_CLOSING_HOUR)
    elsif time_asked.sunday?
      time_asked.hour.between?(SUNDAY_OPENING_HOUR, SUNDAY_CLOSING_HOUR)
    else
      time_asked.hour.between?(WEEKDAY_OPENING_HOUR, WEEKDAY_CLOSING_HOUR)
    end
  end

  def today_closing_hour
    return SATURDAY_CLOSING_HOUR if @time.saturday?
    return SUNDAY_CLOSING_HOUR if @time.sunday?
    return WEEKDAY_CLOSING_HOUR
  end

  def format_time(time_asked = @time)
    time_asked.strftime("%d/%m/%Y %I:%M %p")
  end
end

service = CarCleaningService.new

puts "Program instructions:"
puts "To add a car, input 'add <car_id> [required_time]'."
puts "To pick up a car, input 'pickup <car_id>'."
puts "To view the current simulation time, input 'time'."
puts "To make hours pass, input 'fwd <number_of_hours>'."
puts "To view the current queue, input 'queue'."
puts "To exit, input 'exit'.\n"

input = gets.chomp

until input == "exit"
  words = input.split(" ")
  command = words[0]
  case command
  when "add"
    car = words[1]
    required_time = words[2].nil? ? nil : Time.parse(words[2])
    new_car = Car.new(car, required_time)
    car_validator = CarValidator.new(new_car, service.time)
    car_validator.valid? ? service.add_car(new_car) : puts(car_validator.errors)
  when "pickup"
    car = words[1]
    service.pick_up_car(Car.new car)
  when "time"
    puts "Current simulation time: #{service.time}"
  when "fwd"
    number_of_hours = words[1].to_i
    service.simulate_service(number_of_hours)
  when "queue"
    puts "Current cars in queue:\n#{service.queue}"
  else 
    puts "Unknown command. Try again."
  end
  input = gets.chomp
end
