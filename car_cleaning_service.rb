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
  CAR_CLEANING_TIME = 20
  attr_reader :queue
  def initialize()
    @queue = Queue.new
    @ready = {}
    self.init_threads
  end
  public
  def add_car(car)
    @queue.push(car)
    puts "Car #{car.to_s} queued for servicing. Estimated waiting time until car is serviced: #{waiting_time}"
  end
  def pick_up_car(car)
    if @ready.has_key?(car.to_sym)
      @ready.delete(car.to_sym)
      puts "Car #{car} picked up successfuly!"
    else
      puts "Car #{car} is not ready for pick up!"
    end
  end
  private
  def init_threads
    @threads = 2.times.map {
        Thread.new {
          while true
          car = @queue.pop
          unless car.nil?
            sleep CAR_CLEANING_TIME
            @ready[car.to_sym] = car
            puts "Car #{car.to_s} cleaned & ready to pick up!"
          end
        end 
      }
    }
  end
  def waiting_time
    @queue.length * CAR_CLEANING_TIME
  end
end

service = CarCleaningService.new

puts "Program instructions:"
puts "To add a car, input 'add <car_id>."
puts "To pick up a car, input 'pickup <car_id>."
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
  else 
    puts "Unknown command. Try again."
  end
  command = gets.chomp
end