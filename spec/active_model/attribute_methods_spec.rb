describe ActiveModel::AttributeMethods do
  describe '.attribute_method_prefix' do
    before do
      @klass = Class.new do
        include ActiveModel::AttributeMethods

        attr_accessor :name
        attribute_method_prefix 'clear_'
        define_attribute_methods :name

        private

        def clear_attribute(attr)
          send("#{attr}=", nil)
        end
      end
    end

    it 'defines methods with prefix for all attributes' do
      person = @klass.new
      person.name = 'Bob'
      person.name.should == 'Bob'
      person.clear_name
      person.name.should == nil
    end
  end

  describe '.attribute_method_suffix' do
    before do
      @klass = Class.new do
        include ActiveModel::AttributeMethods

        attr_accessor :name
        attribute_method_suffix '_short?'
        define_attribute_methods :name

        private

        def attribute_short?(attr)
          send(attr).length < 5
        end
      end
    end

    it 'defines methods with suffix for all attributes' do
      person = @klass.new
      person.name = 'Bob'
      person.name.should == 'Bob'
      person.name_short?.should == true
    end
  end

  describe '.attribute_method_affix' do
    before do
      @klass = Class.new do
        include ActiveModel::AttributeMethods

        attr_accessor :name
        attribute_method_affix prefix: 'reset_', suffix: '_to_default!'
        define_attribute_methods :name

        private

        def reset_attribute_to_default!(attr)
          send("#{attr}=", 'Default Name')
        end
      end
    end

    it 'defines methods with prefix and suffix for all attributes' do
      person = @klass.new
      person.name = 'Bob'
      person.name.should == 'Bob'
      person.reset_name_to_default!
      person.name.should == 'Default Name'
    end
  end

  describe '.alias_attribute' do
    before do
      @klass = Class.new do
        include ActiveModel::AttributeMethods

        attr_accessor :name
        attribute_method_suffix '_short?'
        define_attribute_methods :name

        alias_attribute :nickname, :name

        private

        def attribute_short?(attr)
          send(attr).length < 5
        end
      end
    end

    it 'makes aliases for attributes' do
      person = @klass.new
      person.name = 'Bob'
      person.name.should == "Bob"
      person.nickname.should == "Bob"
      person.name_short?.should == true
      person.nickname_short?.should == true
    end
  end

  describe '.attribute_alias?' do
    before do
      @klass = Class.new do
        include ActiveModel::AttributeMethods

        attr_accessor :name
        alias_attribute :nickname, :name
      end
    end

    it 'checks if attribute is alias' do
      @klass.attribute_alias?(:name).should == false
      @klass.attribute_alias?(:nickname).should == true
    end
  end

  describe '.attribute_alias' do
    before do
      @klass = Class.new do
        include ActiveModel::AttributeMethods

        attr_accessor :name
        alias_attribute :nickname, :name
      end
    end

    it 'returns original name for alias' do
      @klass.attribute_alias(:name).should == nil
      @klass.attribute_alias(:nickname).should == 'name'
    end
  end

  describe '.undefine_attribute_methods' do
    before do
      @klass = Class.new do
        include ActiveModel::AttributeMethods

        attr_accessor :name
        attribute_method_suffix '_short?'
        define_attribute_methods :name

        private

        def attribute_short?(attr)
          send(attr).length < 5
        end
      end
    end

    # does not work because of Module#undef_method bug
    # it 'removes all defined methods' do
    #   person = @klass.new
    #   person.name = 'Bob'
    #   person.name_short?.should == true

    #   @klass.undefine_attribute_methods
    #   lambda { person.name_short? }.should.raise(NoMethodError)
    # end
  end
end
