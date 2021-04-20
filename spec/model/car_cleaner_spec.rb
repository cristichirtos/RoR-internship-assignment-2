require_relative '../../model/car_cleaner'

describe CarCleaner do
  let(:car_cleaner_empty) { CarCleaner.new }
  let(:car_cleaner_with_data) { CarCleaner.new(["Test", "Another Test"]) }
  
  it "stores an array as a queue" do

    expect(car_cleaner_empty.queue).to eq []
    expect(car_cleaner_with_data.queue). to eq ["Test", "Another Test"]
  end

end
