class CarCleaningSystemView

  def print_menu
    puts 'Program instructions:'
    puts "To add a car, input 'add <car_id> [required_time]'."
    puts "To pick up a car, input 'pickup <car_id>'."
    puts "To view the current simulation time, input 'time'."
    puts "To make hours pass, input 'fwd <number_of_hours>'."
    puts "To view the current queue, input 'queue'."
    puts "To exit, input 'exit'.\n"
  end

  def get_command
    print '>'
    STDIN.gets.chomp
  end

  def print_result(result)
    puts result
  end
  
end
