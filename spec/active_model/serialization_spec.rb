describe ActiveModel::Serialization do
  describe '#serializable_hash' do
    it 'returns a serialized hash' do
      person_class = Class.new do
        include ActiveModel::Serialization

        attr_accessor :name, :age

        def attributes
          {'name' => nil, 'age' => nil}
        end

        def capitalized_name
          name.capitalize
        end
      end

      person = person_class.new
      person.name = 'bob'
      person.age = 22
      person.serializable_hash.should == { "name" => "bob", "age" => 22 }
      person.serializable_hash(only: :name).should == { "name" => "bob" }
      person.serializable_hash(except: :name).should == { "age" => 22 }
      person.serializable_hash(methods: :capitalized_name)
        .should == { "name" => "bob", "age" => 22, "capitalized_name" => "Bob" }
    end
  end
end
