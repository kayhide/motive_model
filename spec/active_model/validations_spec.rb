describe ActiveModel::Validations do
  describe '.validate_each' do
    it 'validates each attribute against a block' do
      klass = Class.new do
        include ActiveModel::Validations

        attr_accessor :first_name, :last_name

        validates_each :first_name, :last_name do |record, attr, value|
          record.errors.add attr, 'starts with z.' if value.to_s[0] == ?z
        end

        def self.name
          'Person'
        end
      end

      person = klass.new
      person.valid?.should == true
      person.invalid?.should == false

      person.first_name = 'zoolander'
      person.valid?.should == false
      person.invalid?.should == true
      person.errors.messages.should == { first_name: ["starts with z."] }
    end
  end

  describe '.validate' do
    before do
      @person_class = Class.new do
        attr_accessor :friends
        def friend_of? person
          (friends || []).include? person
        end
      end
    end

    it 'validates with a symbol pointing to a method' do
      comment_class = Class.new do
        include ActiveModel::Validations

        validate :must_be_friends

        def must_be_friends
          errors.add(:base, 'must be friends to leave a comment') unless commenter.friend_of?(commentee)
        end

        attr_accessor :commenter, :commentee
      end

      comment = comment_class.new
      comment.commenter = @person_class.new
      comment.valid?.should == false
      comment.errors.messages.should == { base: ['must be friends to leave a comment'] }

      comment.commentee = @person_class.new
      comment.commenter.friends = [comment.commentee]
      comment.valid?.should == true
    end

    it 'validates with a block which is passed with the current record to be validated' do
      comment_class = Class.new do
        include ActiveModel::Validations

        validate do |comment|
          comment.must_be_friends
        end

        def must_be_friends
          errors.add(:base, 'must be friends to leave a comment') unless commenter.friend_of?(commentee)
        end

        attr_accessor :commenter, :commentee
      end

      comment = comment_class.new
      comment.commenter = @person_class.new
      comment.valid?.should == false
      comment.errors.messages.should == { base: ['must be friends to leave a comment'] }

      comment.commentee = @person_class.new
      comment.commenter.friends = [comment.commentee]
      comment.valid?.should == true
    end

    it 'validates with a block where self points to the current record to be validated' do
      comment_class = Class.new do
        include ActiveModel::Validations

        validate do
          errors.add(:base, 'must be friends to leave a comment') unless commenter.friend_of?(commentee)
        end

        attr_accessor :commenter, :commentee
      end

      comment = comment_class.new
      comment.commenter = @person_class.new
      comment.valid?.should == false
      comment.errors.messages.should == { base: ['must be friends to leave a comment'] }

      comment.commentee = @person_class.new
      comment.commenter.friends = [comment.commentee]
      comment.valid?.should == true
    end
  end

  describe '.validators' do
    it 'lists all validators' do
      my_validator_class = Class.new(ActiveModel::Validator)
      other_validator_class = Class.new(ActiveModel::Validator)
      strict_validator_class = Class.new(ActiveModel::Validator)

      person_class = Class.new do
        include ActiveModel::Validations

        validates_with my_validator_class
        validates_with other_validator_class, on: :create
        validates_with strict_validator_class, strict: true
      end

      person_class.validators.map { |v| [v.class, v.options] }
        .should == [
        [my_validator_class, {}],
        [other_validator_class, { on: :create }],
        [strict_validator_class, { strict: true }]
      ]
    end
  end

  describe '.clear_validators!' do
    it 'clears all of the validators and validations' do
      my_validator_class = Class.new(ActiveModel::Validator)
      other_validator_class = Class.new(ActiveModel::Validator)
      strict_validator_class = Class.new(ActiveModel::Validator)

      person_class = Class.new do
        include ActiveModel::Validations

        validates_with my_validator_class
        validates_with other_validator_class, on: :create
        validates_with strict_validator_class, strict: true
        validate :cannot_be_robot

        def cannot_be_robot
          errors.add(:base, 'cannot be a robot') if person_is_robot
        end
      end

      person_class.validators.should.not == []
      person_class._validate_callbacks.empty?.should.not == true
      person_class.clear_validators!
      person_class.validators.should == []
      person_class._validate_callbacks.empty?.should == true
    end
  end

  describe '.validators_on' do
    it 'lists all validators that are being used to validate a specific attribute' do
      person_class = Class.new do
        include ActiveModel::Validations

        attr_accessor :name, :age

        validates_presence_of :name
        validates_inclusion_of :age, in: 0..99
      end

      person_class.validators_on(:name).map { |v| [v.class, v.attributes, v.options] }
        .should == [
        [ActiveModel::Validations::PresenceValidator, [:name], {}]
      ]
    end
  end

  describe '.attribute_method?' do
    it 'returns if attribute is an attribute method' do
      person_class = Class.new do
        include ActiveModel::Validations

        attr_accessor :name
      end

      person_class.attribute_method?(:name).should == true
      person_class.attribute_method?(:age).should == false
    end
  end

  describe '#errors' do
    it 'returns the errors' do
      person_class = Class.new do
        include ActiveModel::Validations

        attr_accessor :name
        validates_presence_of :name

        def self.name
          'Person'
        end
      end

      person = person_class.new
      person.valid?.should == false
      person.errors.class.should == ActiveModel::Errors
      person.errors.messages.should == { name: ["can't be blank"] }
    end
  end

  describe '#valid?' do
    it 'runs all the specified validations and returns if no errors were added' do
      person_class = Class.new do
        include ActiveModel::Validations

        attr_accessor :name
        validates_presence_of :name

        def self.name
          'Person'
        end
      end

      person = person_class.new
      person.name = ''
      person.valid?.should == false
      person.name = 'david'
      person.valid?.should == true
    end

    it 'takes context to select callbacks' do
      person_class = Class.new do
        include ActiveModel::Validations

        attr_accessor :name
        validates_presence_of :name, on: :new

        def self.name
          'Person'
        end
      end

      person = person_class.new
      person.valid?.should == true
      person.valid?(:new).should == false
    end
  end

  describe '#invalid?' do
    it 'performs the opposite of #valid?' do
      person_class = Class.new do
        include ActiveModel::Validations

        attr_accessor :name
        validates_presence_of :name

        def self.name
          'Person'
        end
      end

      person = person_class.new
      person.name = ''
      person.invalid?.should == true
      person.name = 'david'
      person.invalid?.should == false
    end

    it 'takes context to select callbacks' do
      person_class = Class.new do
        include ActiveModel::Validations

        attr_accessor :name
        validates_presence_of :name, on: :new

        def self.name
          'Person'
        end
      end

      person = person_class.new
      person.invalid?.should == false
      person.invalid?(:new).should == true
    end
  end

  describe '#read_attribute_for_validation' do
    it 'hooks method defining how an attribute value should be retrieved' do
      person_class = Class.new do
        include ActiveModel::Validations

        validates_presence_of :name

        def initialize data = {}
          @data = data
        end

        def read_attribute_for_validation key
          @data[key]
        end

        def self.name
          'Person'
        end
      end

      person_class.new.valid?.should == false
      person_class.new(name: 'david').valid?.should == true
    end
  end
end
