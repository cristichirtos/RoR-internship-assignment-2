require_relative '../../../model/validator/car_validator'

describe CarValidator do
  before { Timecop.freeze(Time.local(2021, 4, 20, 8, 0, 0)) }
  
  context 'with invalid id' do
    subject { CarValidator.new(Car.new('some_random_id'), Time.now) }

    it 'fails to validate' do
      response = subject.valid?

      expect(response).to eq false
    end

    it 'specifies what the error is' do
      subject.valid?
      response = subject.errors

      expect(response).to eq ['Invalid car identification number.']
    end

  end

  context 'with invalid required_date' do
    subject { CarValidator.new(Car.new('CJ30TST', Time.parse('2005-12-04')), Time.now) }

    it 'fails to validate' do
      response = subject.valid?

      expect(response).to eq false
    end

    it 'specifies what the error is' do
      subject.valid?
      response = subject.errors

      expect(response).to eq ['Required time cannot be before the current time.']
    end

  end

  context 'with valid data' do
    subject { CarValidator.new(Car.new('CJ30TST', Time.parse('2021-4-21')), Time.now) }

    it 'validates successfully' do
      response = subject.valid?

      expect(response).to eq true
    end

    it 'has no errors' do
      subject.valid?
      response = subject.errors

      expect(response).to eq []
    end

  end
end
