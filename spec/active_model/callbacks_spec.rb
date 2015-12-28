describe ActiveModel::Callbacks do
  before do
    @model_class = Class.new do
      validator_class = Class.new do
        def around_create(model)
          model.callbacks << :before_around_create
          yield
          model.callbacks << :after_around_create
          false
        end
      end

      attr_reader :callbacks
      extend ActiveModel::Callbacks

      define_model_callbacks :create
      define_model_callbacks :initialize, only: :after
      define_model_callbacks :multiple,   only: [:before, :around]
      define_model_callbacks :empty,      only: []

      before_create :before_create
      around_create validator_class.new

      after_create do |model|
        model.callbacks << :after_create
        false
      end

      after_create do |model|
        model.callbacks << :final_callback
      end

      def initialize(valid=true)
        @callbacks, @valid = [], valid
      end

      def before_create
        @callbacks << :before_create
      end

      def create
        run_callbacks :create do
          @callbacks << :create
          @valid
        end
      end
    end
  end

  it "completes callback chain" do
    model = @model_class.new
    model.create
    model.callbacks.should == [
      :before_create, :before_around_create, :create,
      :after_around_create, :after_create, :final_callback
    ]
  end

  it "does not execute after callbacks if the block returns false" do
    model = @model_class.new(false)
    model.create
    model.callbacks.should == [
      :before_create, :before_around_create,
      :create, :after_around_create
    ]
  end

  it "only selects which types of callbacks should be created" do
    @model_class.respond_to?(:before_initialize).should == false
    @model_class.respond_to?(:around_initialize).should == false
    @model_class.respond_to?(:after_initialize).should == true
  end

  it "only selects which types of callbacks should be created from an array list" do
    @model_class.respond_to?(:before_multiple).should == true
    @model_class.respond_to?(:around_multiple).should == true
    @model_class.respond_to?(:after_multiple).should == false
  end

  it "creates no callbacks" do
    @model_class.respond_to?(:before_empty).should == false
    @model_class.respond_to?(:around_empty).should == false
    @model_class.respond_to?(:after_empty).should == false
  end

  describe 'with inheritance' do
    before do
      @violin_class = Class.new do
        attr_reader :history
        def initialize
          @history = []
        end
        extend ActiveModel::Callbacks
        define_model_callbacks :create
        def callback1; self.history << 'callback1'; end
        def callback2; self.history << 'callback2'; end
        def create
          run_callbacks(:create) {}
          self
        end
      end

      @violin1_class = Class.new(@violin_class) do
        after_create :callback1, :callback2
      end

      @violin2_class = Class.new(@violin_class) do
        after_create :callback1
        after_create :callback2
      end
    end

    it "after_create callbacks with both callbacks declared in one line" do
      @violin1_class.new.create.history.should == ["callback1", "callback2"]
    end

    it "after_create callbacks with both callbacks declared in different lines" do
      @violin2_class.new.create.history.should == ["callback1", "callback2"]
    end
  end
end
