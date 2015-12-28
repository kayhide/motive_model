describe ActiveModel::ForbiddenAttributesProtection do
  before do
    @model_class = Class.new do
      include ActiveModel::ForbiddenAttributesProtection

      public :sanitize_for_mass_assignment
    end

    @params_class = Class.new do
      attr_accessor :permitted
      alias_method :permitted?, :permitted

      delegate :keys, :key?, :has_key?, :empty?, to: :@parameters

      def initialize(attributes)
        @parameters = attributes
        @permitted = false
      end

      def permit!
        @permitted = true
        self
      end

      def to_h
        @parameters
      end
    end
  end

  it  "raises if not permitted" do
    params = @params_class.new(a: "b")
    lambda {
      @model_class.new.sanitize_for_mass_assignment(params)
    }.should.raise(ActiveModel::ForbiddenAttributesError)
  end

  it "updates with permitted attributes" do
    params = @params_class.new(a: "b").permit!
    @model_class.new.sanitize_for_mass_assignment(params).to_h.should == { a: "b" }
  end

  it "allows regular attributes" do
    @model_class.new.sanitize_for_mass_assignment(a: "b").should == { a: "b" }
  end
end
