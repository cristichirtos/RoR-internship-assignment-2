require_relative '../../model/car'

describe Car do
  let(:car) { Car.new("CJ30PXP", "2020-11-24") }
  
  it "stores an id and a date" do

    expect(car).to have_attributes(id: "CJ30PXP", required_time: "2020-11-24")
  end

end