describe ActiveModel::Translation do
  describe '#human_attribute_name' do
    it 'transforms attribute names into a more human format' do
      klass = Class.new do
        extend ActiveModel::Translation

        def self.name
          'Person'
        end
      end

      klass.human_attribute_name('first_name').should == 'First name'
    end
  end
end
