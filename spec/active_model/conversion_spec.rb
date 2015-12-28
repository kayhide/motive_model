describe ActiveModel::Conversion do
  describe '#to_model' do
    before do
      @klass = Class.new do
        include ActiveModel::Conversion
      end
    end

    it 'returns self' do
      person = @klass.new
      person.to_model.should == person
    end
  end

  describe '#to_key' do
    before do
      @klass = Class.new do
        include ActiveModel::Conversion
        attr_accessor :id
      end
    end

    it 'returns all key attributes if any is set' do
      person = @klass.new
      person.id = 1
      person.to_key.should == [1]
    end
  end

  describe '#to_param' do
    before do
      @klass = Class.new do
        include ActiveModel::Conversion
        attr_accessor :id
        def persisted?
          true
        end
      end
    end

    it 'returns a string representing the object key suitable for use in URLs' do
      person = @klass.new
      person.id = 1
      person.to_param.should == '1'
    end
  end

  describe '#to_partial_path' do
    before do
      @klass = Class.new do
        include ActiveModel::Conversion
        def self.name
          'Person'
        end
      end
    end

    it 'returns a string identifying the path associated with the object' do
      person = @klass.new
      person.to_partial_path.should == 'people/person'
    end
  end
end
