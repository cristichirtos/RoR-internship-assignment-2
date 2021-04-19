require'time'

class Car
  attr_reader :id

  def initialize(id)
    @id = id
  end

  def to_s
    @id
  end

  def to_sym
    @id.to_sym
  end
end

class CarCleaningService

  MAX_CARS_AT_ONCE = 2
  CAR_CLEANING_TIME = 2
  ONE_HOUR_IN_SECONDS = 3600

  attr_reader :time

  def initialize(queue = Queue.new)
    @queue = queue
    @ready = {}
    @processed_cars = 0
    @time = Time.parse(Time.now.strftime("%Y-%m-%dT08:00:00%z"))
    self.init_threads
  end

  public

  def add_car(car)
    @queue.push(car)
    puts "[#{format_time}] Car #{car.to_s} queued for servicing. Estimated waiting time until car is serviced: #{waiting_time} hours."
  end

  def pick_up_car(car)
    if @ready.has_key?(car.to_sym)
      @ready.delete(car.to_sym)
      puts "[#{format_time}] Car #{car} picked up successfuly!"
    else
      puts "[#{format_time}] Car #{car} is not ready for pick up!"
    end

  end

  private

  def init_threads
    @threads = MAX_CARS_AT_ONCE.times.map {
      Thread.new {
        while true
          if self.is_open?
            car = @queue.pop
            sleep CAR_CLEANING_TIME
            process_car(car) unless car.nil?
          else
            sleep CAR_CLEANING_TIME
            puts "[#{format_time}] The service is closed until tomorrow morning."
          end
        end 
      }
    }
  end

  def process_car(car)
    @ready[car.to_sym] = car
    @time += ONE_HOUR_IN_SECONDS * CAR_CLEANING_TIME if @processed_cars % MAX_CARS_AT_ONCE == 0
    @processed_cars += 1
    puts "[#{format_time}] Car #{car.to_s} done cleaning & ready for pick up!"
  end

  def waiting_time
    @queue.length * CAR_CLEANING_TIME
  end

  def is_open?
    @time.hour < 18
  end

  def format_time
    @time.strftime("%d/%m/%Y %I:%M %p")
  end
end

service = CarCleaningService.new

puts "Program instructions:"
puts "To add a car, input 'add <car_id>."
puts "To pick up a car, input 'pickup <car_id>."
puts "To view the current simulation time, input 'time'."
puts "To exit, input 'exit'.\n"
command = gets.chomp

until command == "exit"
  words = command.split(" ")
  cmd = words[0]
  car = words[1]
  case cmd
  when "add"
    service.add_car(Car.new car)
  when "pickup"
    service.pick_up_car(Car.new car)
  when "time"
    puts service.time
  else 
    puts "Unknown command. Try again."
  end
  command = gets.chomp
end
