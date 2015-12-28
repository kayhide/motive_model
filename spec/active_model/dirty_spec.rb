describe ActiveModel::Dirty do
  before do
    @klass = Class.new do
      include ActiveModel::Dirty

      define_attribute_methods :name

      def name
        @name
      end

      def name=(val)
        name_will_change! unless val == @name
        @name = val
      end

      def save
        changes_applied
      end

      def reload!
        clear_changes_information
      end

      def rollback!
        restore_attributes
      end
    end
  end

  describe '#changed?' do
    it 'returns if any attribute have unsaved changes' do
      person = @klass.new
      person.changed?.should == false
      person.name = 'bob'
      person.changed?.should == true
    end
  end

  describe '#changed' do
    it 'returns attributes with unsaved changes' do
      person = @klass.new
      person.changed.should == []
      person.name = 'bob'
      person.changed.should == ['name']
    end
  end

  describe '#changes' do
    it 'returns changed attributes indicating their original' do
      person = @klass.new
      person.name = 'bill'
      person.save
      person.changes.should == {}
      person.name = 'bob'
      person.changes.should == { 'name' => ['bill', 'bob'] }
    end
  end

  describe '#previous_changes' do
    it 'returns attributes that were changed before the model was saved' do
      person = @klass.new
      person.name = 'bob'
      person.save
      person.name = 'robert'
      person.save
      person.previous_changes.should == { 'name' => ['bob', 'robert'] }
    end
  end

  describe '#changed_attributes' do
    it 'returns attributes that were changed before the model was saved' do
      person = @klass.new
      person.name = 'bob'
      person.save
      person.name = 'robert'
      person.changed_attributes.should == { 'name' => 'bob' }
    end
  end
end
