require 'time'
require_relative 'view/car_cleaning_system_view'
require_relative 'service/car_cleaner_service'
require_relative 'controller/car_cleaning_system_controller'

view = CarCleaningSystemView.new
service = CarCleanerService.new(Time.parse(Time.now.strftime("%Y-%m-%dT08:00:00%z")))
controller = CarCleaningSystemController.new(view, service)

controller.start_cleaning_system