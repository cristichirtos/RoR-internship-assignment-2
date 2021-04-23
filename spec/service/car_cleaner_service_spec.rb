require_relative '../../service/car_cleaner_service'
require 'timecop'

describe CarCleanerService do
  before { Timecop.freeze(Time.local(2021, 4, 20, 8, 0, 0)) }
  subject { CarCleanerService.new(Time.now) }
  
  describe '.add_car' do
    let(:car) { Car.new('CJ30TST') }

    it 'adds a car in the queue' do
      result = subject.add_car(car)

      expect(result[0].id).to eq 'CJ30TST'
    end

    let(:car_quickest) { Car.new('CJ29TST', '2021-04-21') }
    let(:car_medium) { Car.new('CJ30TST', '2021-04-22') }
    let(:car_slowest) { Car.new('CJ31TST', '2021-04-23') }

    it 'prioritizes the cars based on the required date' do
      subject.add_car(car_medium)
      subject.add_car(car_slowest)
      result = subject.add_car(car_quickest)

      expect(result[0].id).to eq 'CJ29TST'
      expect(result[1].id).to eq 'CJ30TST'
      expect(result[2].id).to eq 'CJ31TST'
    end
  end

  describe '.simulate_service' do
    let(:car) { Car.new('CJ30TST') }

    it 'makes time pass' do
      subject.add_car(car)
      result = subject.simulate_service(2)

      expect(result).to eq ['[20/04/2021 08:00 AM] Car CJ30TST moved to start cleaning process.', 
                                                             '[20/04/2021 09:00 AM] Nothing significant happened...',
                                                             '[20/04/2021 10:00 AM] Car CJ30TST done cleaning & ready for pick up!',
                                                             '[20/04/2021 10:00 AM] Moved forward in time by 2 hours.']
    end

    it 'signals when service is closed' do
      result = subject.simulate_service(15)

      expect(result[11]).to eq '[20/04/2021 07:00 PM] Car cleaning service is closed until tomorrow morning.'
    end
  end

  describe '.pick_up_car' do
    let(:car) { Car.new('CJ30TST') }

    context 'when car does not exist' do
      it 'fails to pick up the car' do
        result = subject.pick_up_car(car.id)

        expect(result).to eq false
      end
    end

    context 'when car exists' do

      context 'when car is not ready' do
        it 'fails to pick up the car' do
          subject.add_car(car)
          result = subject.pick_up_car(car.id)

          expect(result).to eq false
        end
      end

      context 'when car is ready' do

        it 'picks up the car' do
          subject.add_car(car)
          subject.simulate_service(2)
          result = subject.pick_up_car(car.id)

          expect(result).to eq true
        end

        it 'allows the user to pick up the car later' do
          subject.add_car(car)
          subject.simulate_service(7 * 24) # a week later
          result = subject.pick_up_car(car.id)

          expect(result).to eq true
        end
      end
    end
  end

  describe '.time_ready' do
    let(:car) { Car.new('CJ30TST') }

    it 'gives an estimated time when car will be ready' do
      subject.add_car(car)
      result = subject.time_ready(car)

      expect(result).to eq '20/04/2021 10:00 AM'
    end
  end

  describe '.format_time' do
    let(:time) { Time.now }

    it 'formats a Time object' do
      result = subject.format_time(time)

      expect(result).to eq '20/04/2021 08:00 AM'
    end
  end

  describe '.show_queue' do
    let(:car) { Car.new('CJ30TST') }

    it 'shows the current queue' do
      subject.add_car(car)
      result = subject.show_queue.split(' ')

      expect(result[0]).to eq 'CJ30TST'
    end
  end
end
