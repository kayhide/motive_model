describe ActiveModel::Errors do
  before do
    @klass = Class.new do
      extend ActiveModel::Naming

      def initialize
        @errors = ActiveModel::Errors.new(self)
      end

      attr_accessor :name, :email
      attr_reader   :errors

      def validate!
        errors.add(:name, "can't be nil") if name.nil?
      end

      def read_attribute_for_validation(attr)
        send(attr)
      end

      def self.name
        'Person'
      end

      def self.human_attribute_name(attr, options = {})
        attr
      end

      def self.lookup_ancestors
        [self]
      end
    end
  end

  describe '#clear' do
    it 'clears error messages' do
      person = @klass.new
      person.validate!
      person.errors.full_messages.should == ["name can't be nil"]
      person.errors.clear
      person.errors.full_messages.should == []
    end
  end

  describe '#include?' do
    it 'returns if error messages include an error' do
      person = @klass.new
      person.validate!
      person.errors.messages.should == {:name=>["can't be nil"]}
      person.errors.include?(:name).should == true
      person.errors.include?(:age).should == false
    end
  end

  describe '#get' do
    it 'gets messages' do
      person = @klass.new
      person.validate!
      person.errors.messages.should == {:name=>["can't be nil"]}
      person.errors.get(:name).should == ["can't be nil"]
      person.errors.get(:age).should == nil
    end
  end

  describe '#set' do
    it 'sets messages' do
      person = @klass.new
      person.validate!
      person.errors.get(:name).should == ["can't be nil"]
      person.errors.set(:name, ["must not be nil"])
      person.errors.get(:name).should == ["must not be nil"]
    end
  end

  describe '#delete' do
    it 'deletes messages' do
      person = @klass.new
      person.validate!
      person.errors.get(:name).should == ["can't be nil"]
      person.errors.delete(:name).should == ["can't be nil"]
      person.errors.get(:name).should == nil
    end
  end

  describe '#[]' do
    it 'returns errors' do
      person = @klass.new
      person.validate!
      person.errors[:name].should == ["can't be nil"]
      person.errors['name'].should == ["can't be nil"]
    end
  end

  describe '#[]=' do
    it 'adds error message' do
      person = @klass.new
      person.validate!
      person.errors[:name] = "must be set"
      person.errors[:name].should == ["can't be nil", "must be set"]
    end
  end

  describe '#each' do
    it 'yields attribute and error' do
      person = @klass.new
      person.errors.add(:name, "can't be nil")
      person.errors.add(:name, "must be set")
      errors = []
      person.errors.each do |attribute, error|
        errors << [attribute, error]
      end
      errors.should == [
        [:name, "can't be nil"],
        [:name, "must be set"]
      ]
    end
  end

  describe '#size' do
    it 'returns number of error messages' do
      person = @klass.new
      person.errors.add(:name, "can't be nil")
      person.errors.size.should == 1
      person.errors.add(:name, "must be set")
      person.errors.size.should == 2
    end
  end

  describe '#values' do
    it 'returns all message values' do
      person = @klass.new
      person.errors.add(:name, "can't be nil")
      person.errors.add(:name, "must be set")
      person.errors.values.should == [["can't be nil", "must be set"]]
    end
  end

  describe '#keys' do
    it 'returns all message keys' do
      person = @klass.new
      person.errors.add(:name, "can't be nil")
      person.errors.add(:name, "must be set")
      person.errors.keys.should == [:name]
    end
  end

  describe '#to_a' do
    it 'returns error messages with the attribute name included' do
      person = @klass.new
      person.errors.add(:name, "can't be nil")
      person.errors.add(:name, "must be set")
      person.errors.to_a.should == ["name can't be nil", "name must be set"]
    end
  end

  describe '#count' do
    it 'returns number of error messages' do
      person = @klass.new
      person.errors.add(:name, "can't be nil")
      person.errors.count.should == 1
      person.errors.add(:name, "must be set")
      person.errors.count.should == 2
    end
  end

  describe '#empty?' do
    it 'returns if no errors are found' do
      person = @klass.new
      person.errors.empty?.should == true
      person.errors.add(:name, "can't be nil")
      person.errors.empty?.should == false
    end
  end

  describe '#to_xml' do
    it 'returns xml formatted representation' do
      person = @klass.new
      person.errors.add(:name, "can't be blank")
      person.errors.add(:name, "must be specified")
      person.errors.to_xml.should == <<EOS
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<errors>
  <error>name can't be blank</error>
  <error>name must be specified</error>
</errors>
EOS
    end
  end

  describe '#as_json' do
    it 'returns hash for json representation' do
      person = @klass.new
      person.errors.add(:name, "can't be nil")
      person.errors.as_json.should == { name: ["can't be nil"] }
      person.errors.as_json(full_messages: true)
        .should == { name: ["name can't be nil"] }
    end
  end

  describe '#to_hash' do
    it 'returns hash of attributes' do
      person = @klass.new
      person.errors.add(:name, "can't be nil")
      person.errors.to_hash.should == { name: ["can't be nil"] }
      person.errors.to_hash(true)
        .should == { name: ["name can't be nil"] }
    end
  end

  describe '#add' do
    class NameIsInvalid < ActiveModel::StrictValidationFailed
    end

    it 'adds message to the error messages on attribute' do
      person = @klass.new
      person.errors.add(:name).should ==  ["is invalid"]
      person.errors.add(:name, 'must be implemented')
        .should == ["is invalid", "must be implemented"]

      person.errors.messages
        .should == { name: ["is invalid", "must be implemented"] }
    end

    it 'raises if strict option is true' do
      person = @klass.new
      lambda {
        person.errors.add(:name, :invalid, strict: true)
      }.should.raise(ActiveModel::StrictValidationFailed)

      lambda {
        person.errors.add(:name, nil, strict: NameIsInvalid)
      }.should.raise(NameIsInvalid)

      person.errors.messages.should == {}
    end
  end

  describe '#add_on_empty' do
    it 'adds an error message on empty attributes' do
      person = @klass.new
      person.errors.add_on_empty(:name)
      person.errors.messages.should == { name: ["can't be empty"] }
    end
  end

  describe '#add_on_blank' do
    it 'adds an error message on empty attributes' do
      person = @klass.new
      person.errors.add_on_blank(:name)
      person.errors.messages.should == { name: ["can't be blank"] }
    end
  end

  describe '#added?' do
    it 'adds an error message on empty attributes' do
      person = @klass.new
      person.errors.add(:name, :blank)
      person.errors.added?(:name, :blank).should == true
    end
  end

  describe '#full_messages' do
    it 'returns all the full error messages' do
      person = @klass.new
      person.errors.add(:name, :invalid)
      person.errors.add(:name, :blank)
      person.errors.add(:email, :blank)
      person.errors.full_messages
        .should == [
        "name is invalid",
        "name can't be blank",
        "email can't be blank"
      ]
    end
  end

  describe '#full_messages_for' do
    it 'returns all the full error messages for attribute' do
      person = @klass.new
      person.errors.add(:name, :invalid)
      person.errors.add(:name, :blank)
      person.errors.add(:email, :blank)
      person.errors.full_messages_for(:name)
        .should == [
        "name is invalid",
        "name can't be blank"
      ]
    end
  end

  describe '#full_message' do
    it 'returns a full error message for attribute' do
      person = @klass.new
      person.errors.full_message(:name, 'is invalid')
        .should == "name is invalid"
    end
  end
end
