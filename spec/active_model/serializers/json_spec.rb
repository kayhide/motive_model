describe ActiveModel::Serializers::JSON do
  describe '#as_json' do
    before do
      @user_class = Class.new do
        include ActiveModel::Serializers::JSON
        attr_accessor :id, :name, :age, :created_at, :awesome

        def attributes
          instance_values
        end

        def permalink
          [id, *name.split].join('-').downcase
        end

        def self.find id
          new.tap do |user|
            user.id = id
            user.name = 'Konata Izumi'
            user.age = 16
            user.created_at = Time.new 2006, 8, 1
            user.awesome = true
          end
        end

        def self.name
          'User'
        end
      end
    end

    it 'returns a hash representing the model' do
      user = @user_class.find(1)
      user.as_json.should == {
        'id' => 1, 'name' => 'Konata Izumi', 'age' => 16,
        'created_at' => Time.new(2006, 8, 1), 'awesome' => true
      }
    end

    it 'emits a single root node if include_root_in_json option is true' do
      @user_class.include_root_in_json = true
      user = @user_class.find(1)
      user.as_json.should == {
        'user' => {
          'id' => 1, 'name' => 'Konata Izumi', 'age' => 16,
          'created_at' => Time.new(2006, 8, 1), 'awesome' => true
        }
      }
    end

    it 'emits a single root node with :root option' do
      user = @user_class.find(1)
      user.as_json(root: true).should == {
        'user' => {
          'id' => 1, 'name' => 'Konata Izumi', 'age' => 16,
          'created_at' => Time.new(2006, 8, 1), 'awesome' => true
        }
      }
    end

    it 'limits the attributes included with :only and :except options' do
      user = @user_class.find(1)
      user.as_json(only: [:id, :name]).should == {
        'id' => 1, 'name' => 'Konata Izumi'
      }
      user.as_json(except: [:id, :created_at, :age]).should == {
        'name' => 'Konata Izumi', 'awesome' => true
      }
    end

    it 'includes the result of some method calls on the model with :methods option' do
      user = @user_class.find(1)
      user.as_json(methods: :permalink).should == {
        'id' => 1, 'name' => 'Konata Izumi', 'age' => 16,
        'created_at' => Time.new(2006, 8, 1), 'awesome' => true,
        'permalink' => '1-konata-izumi'
      }
    end

    it 'includes associations with :include option' do
      post_class = Class.new do
        include ActiveModel::Serializers::JSON
        attr_accessor :id, :author_id, :title

        def attributes
          instance_values
        end

        def self.all
          [
            new.tap do |post|
              post.id = 1
              post.author_id = 1
              post.title = 'Welcome to the weblog'
            end,
            new.tap do |post|
              post.id = 2
              post.author_id = 1
              post.title = 'So I was thinking'
            end
          ]
        end
      end

      comment_class = Class.new do
        include ActiveModel::Serializers::JSON
        attr_accessor :post_id, :body

        def attributes
          instance_values
        end

        def self.all
          [
            new.tap do |comment|
              comment.post_id = 1
              comment.body = "1st post!"
            end,
            new.tap do |comment|
              comment.post_id = 1
              comment.body = "Second!"
            end,
            new.tap do |comment|
              comment.post_id = 2
              comment.body = "Don't think too hard"
            end
          ]
        end
      end

      @user_class.send :define_method, :posts do
        post_class.all.select { |post| post.author_id == id }
      end

      post_class.send :define_method, :comments do
        comment_class.all.select { |comment| comment.post_id == id }
      end

      user = @user_class.find(1)
      user.as_json(include: :posts).should == {
        "id" => 1, "name" => "Konata Izumi", "age" => 16,
        "created_at" => Time.new(2006, 8, 1), "awesome" => true,
        "posts" => [
          { "id" => 1, "author_id" => 1, "title" => "Welcome to the weblog" },
          { "id" => 2, "author_id" => 1, "title" => "So I was thinking" }
        ]
      }

      user = @user_class.find(1)
      user.as_json(
        include: {
          posts: {
            include: {
              comments: { only: :body } },
            only: :title } }
      ).should == {
        "id" => 1, "name" => "Konata Izumi", "age" => 16,
        "created_at" => Time.new(2006, 8, 1), "awesome" => true,
        "posts" => [
          { "comments" => [ { "body" => "1st post!" }, { "body" => "Second!" } ],
            "title" => "Welcome to the weblog" },
          { "comments" => [ { "body" => "Don't think too hard" } ],
            "title" => "So I was thinking" }
        ]
      }
    end

    describe '#from_json' do
      before do
        @person_class = Class.new do
          include ActiveModel::Serializers::JSON
          attr_accessor :name, :age, :awesome

          def attributes=(hash)
            hash.each do |key, value|
              send("#{key}=", value)
            end
          end

          def attributes
            instance_values
          end
        end
      end

      it 'sets the model attributes from a JSON string' do
        json = { name: 'bob', age: 22, awesome: true }.to_json
        person = @person_class.new
        person.from_json(json).should == person
        person.name.should == 'bob'
        person.age.should == 22
        person.awesome.should == true
      end

      it 'takes a JSON string with root' do
        json = { person: { name: 'bob', age: 22, awesome: true } }.to_json
        person = @person_class.new
        person.from_json(json, true).should == person
        person.name.should == 'bob'
        person.age.should == 22
        person.awesome.should == true
      end
    end
  end
end
