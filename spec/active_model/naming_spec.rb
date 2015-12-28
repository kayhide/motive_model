describe ActiveModel::Naming do
  module BookModule
    class BookCover
      extend ActiveModel::Naming
    end
  end

  describe '#model_name' do
    it 'returns ActiveModel::Name object for module' do
      @klass = Class.new do
        extend ActiveModel::Naming

        def self.name
          'BookCover'
        end
      end
      @klass.model_name.name.should == 'BookCover'
      @klass.model_name.human.should == 'Book cover'
      @klass.model_name.i18n_key == :book_cover
      BookModule::BookCover.model_name.i18n_key == :'book_module/book_cover'
    end

    it 'returns ActiveModel::Name object for module' do
      @klass = Class.new do
        extend ActiveModel::Naming

        def self.name
          'Person'
        end
      end
      @klass.model_name.name.should == 'Person'
      @klass.model_name.should.class == ActiveModel::Name
      @klass.model_name.singular == 'person'
      @klass.model_name.plural == 'people'
    end
  end

  module Highrise
    class Person
      extend ActiveModel::Naming
    end
  end

  describe '.plural' do
    it 'returns the plural class name of a record or class' do
      klass = Class.new do
        extend ActiveModel::Naming
        def self.name
          'Post'
        end
      end
      post = klass.new
      ActiveModel::Naming.plural(post).should == 'posts'
    end

    it 'works with nested class' do
      ActiveModel::Naming.plural(Highrise::Person).should == 'highrise_people'
    end
  end

  describe '.singular' do
    it 'returns the singular class name of a record or class' do
      klass = Class.new do
        extend ActiveModel::Naming
        def self.name
          'Post'
        end
      end
      post = klass.new
      ActiveModel::Naming.singular(post).should == 'post'
    end

    it 'works with nested class' do
      ActiveModel::Naming.singular(Highrise::Person).should == 'highrise_person'
    end
  end

  describe '.uncountable?' do
    it 'identifies whether the class name of a record or class is uncountable' do
      sheep_class = Class.new do
        extend ActiveModel::Naming
        def self.name
          'Sheep'
        end
      end
      ActiveModel::Naming.uncountable?(sheep_class).should == true

      post_class = Class.new do
        extend ActiveModel::Naming
        def self.name
          'Post'
        end
      end
      ActiveModel::Naming.uncountable?(post_class).should == false
    end
  end
end
