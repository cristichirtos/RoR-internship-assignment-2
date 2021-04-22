require_relative '../view/car_cleaning_system_view'
require_relative '../service/car_cleaner_service'
require_relative '../model/car'
require_relative '../model/validator/car_validator'

class CarCleaningSystemController

  attr_reader :car_cleaning_system_view, :car_cleaner_service
  
  def initialize(car_cleaning_system_view, car_cleaner_service)
    @car_cleaning_system_view = car_cleaning_system_view
    @car_cleaner_service = car_cleaner_service
  end

  def start_cleaning_system
    car_cleaning_system_view.print_menu
    input = car_cleaning_system_view.get_command

    until input == 'exit'
      words = input.split(" ")
      command = words[0]

      case command
      when 'add'
        id = words[1]
        time = words[2]
        on_add(id, time)

      when 'pickup'
        id = words[1]
        on_pickup(id)

      when 'time'
        on_time

      when 'fwd'
        number_of_hours = words[1].to_i
        on_fwd(number_of_hours)
  
      when 'queue'
        on_queue
      
      else 
        car_cleaning_system_view.print_result('Unknown command. Try again.')
      end
      
      input = car_cleaning_system_view.get_command
    end
  end

  private

  def on_add(id, time)
    required_time = Time.parse(time) unless time.nil?
    car = Car.new(id, required_time)
    car_validator = CarValidator.new(car, car_cleaner_service.time)

    if car_validator.valid?
      car_cleaner_service.add_car(car)
      result = "[#{car_cleaner_service.format_time}] Car #{id} queued for servicing. Estimated time when car will be ready: #{car_cleaner_service.time_ready(car)}."
      car_cleaning_system_view.print_result(result)
    else
      car_cleaning_system_view.print_result(car_validator.errors)
    end

  rescue ArgumentError
    car_cleaning_system_view.print_result('Invalid date format.')
  end

  def on_pickup(id)
    result = car_cleaner_service.pick_up_car(id) ? "[#{car_cleaner_service.format_time}] Car #{id} picked up successfuly!" 
                                                 : "[#{car_cleaner_service.format_time}] Car #{id} not ready for pick up!"
    car_cleaning_system_view.print_result(result)
  end

  def on_time
    car_cleaning_system_view.print_result("Current simulation time: #{car_cleaner_service.time}")
  end

  def on_fwd(number_of_hours)
    result = car_cleaner_service.simulate_service(number_of_hours)
    car_cleaning_system_view.print_result(result)
  end

  def on_queue
    car_cleaning_system_view.print_result("Current cars in queue:\n#{car_cleaner_service.show_queue}")
  end
end
