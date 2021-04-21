require_relative '../../model/car_cleaner'

describe CarCleaner do
  
  context 'with empty data' do
    subject { CarCleaner.new }

    it 'stores an array as a queue' do
      response = subject

      expect(response.queue).to eq []
    end

  end

  context 'with data' do
    subject { CarCleaner.new(['Test', 'Another Test']) }
  
    it 'stores an array as a queue' do
      response = subject
      
      expect(response.queue). to eq ['Test', 'Another Test']
    end

  end
  
end
