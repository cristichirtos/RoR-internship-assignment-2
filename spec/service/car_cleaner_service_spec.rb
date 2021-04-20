require_relative '../../service/car_cleaner_service'
require 'timecop'

describe CarCleanerService do
  before { Timecop.freeze(Time.local(2021, 4, 20, 8, 0, 0)) }
  let(:car_cleaner_service) { CarCleanerService.new Time.now }
  
  describe ".add_car" do
    let(:car) { Car.new "CJ30TST"}

    it "adds a car in the queue" do

      car_cleaner_service.add_car(car)
      expect(car_cleaner_service.show_queue[0].id).to eq "CJ30TST"
    end

    let(:car_quickest) { Car.new("CJ29TST", "2021-04-21") }
    let(:car_medium) { Car.new("CJ30TST", "2021-04-22") }
    let(:car_slowest) { Car.new("CJ31TST", "2021-04-23") }

    it "prioritizes the cars based on the required date" do

      car_cleaner_service.add_car(car_medium)
      car_cleaner_service.add_car(car_slowest)
      car_cleaner_service.add_car(car_quickest)

      expect(car_cleaner_service.show_queue[0].id).to eq "CJ29TST"
      expect(car_cleaner_service.show_queue[1].id).to eq "CJ30TST"
      expect(car_cleaner_service.show_queue[2].id).to eq "CJ31TST"
    end

  end

  describe ".simulate_service" do
    let(:car) { Car.new "CJ30TST"}

    it "makes time pass" do

      car_cleaner_service.add_car(car)
      expect(car_cleaner_service.simulate_service(2)).to eq ["[20/04/2021 08:00 AM] Car CJ30TST moved to start cleaning process.", 
                                                             "[20/04/2021 09:00 AM] Nothing significant happened...",
                                                             "[20/04/2021 10:00 AM] Car CJ30TST done cleaning & ready for pick up!",
                                                             "[20/04/2021 10:00 AM] Moved forward in time by 2 hours."]
    end

    it "signals when service is closed" do

      expect(car_cleaner_service.simulate_service(15)[11]).to eq "[20/04/2021 07:00 PM] Car cleaning service is closed until tomorrow morning."
    end

  end

end
