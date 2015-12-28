describe ActiveModel::Model do
  describe '#initialize' do
    before do
      @klass = Class.new do
        include ActiveModel::Model
        attr_accessor :name, :age
      end
    end

    it 'sets attributes' do
      person = @klass.new(name: 'bob', age: '18')
      person.name.should == 'bob'
      person.age.should == '18'
    end
  end

  describe '#persisted?' do
    before do
      @klass = Class.new do
        include ActiveModel::Model
        attr_accessor :id, :name
      end
    end

    it 'returns false' do
      person = @klass.new(id: 1, name: 'bob')
      person.persisted?.should == false
    end
  end
end
