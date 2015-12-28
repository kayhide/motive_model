describe ActiveModel::Serializers::Xml do
  describe '#to_xml' do
    before do
      @user_class = Class.new do
        include ActiveModel::Serializers::Xml
        attr_accessor :id, :name, :age, :created_at

        def attributes
          instance_values
        end

        def permalink
          [id, *name.split].join('-').downcase
        end

        def self.find id
          new.tap do |user|
            user.id = id
            user.name = 'Chiang Mai'
            user.age = 16
            user.created_at = '2015/12/29 16:38:27'.to_time(:utc)
          end
        end

        def self.name
          'User'
        end
      end
    end

    it 'returns XML representing the model' do
      user = @user_class.find(1)
      user.to_xml.should == <<EOS
<?xml version="1.0" encoding="UTF-8"?>
<user>
  <id type="integer">1</id>
  <name>Chiang Mai</name>
  <age type="integer">16</age>
  <created-at type="dateTime">2015-12-29T16:38:27Z</created-at>
</user>
EOS
    end

    it 'limits the attributes included with :only and :except options' do
      user = @user_class.find(1)
      user.to_xml(only: [:id, :name]).should == <<EOS
<?xml version="1.0" encoding="UTF-8"?>
<user>
  <id type="integer">1</id>
  <name>Chiang Mai</name>
</user>
EOS
      user.to_xml(except: [:id, :created_at, :age]).should == <<EOS
<?xml version="1.0" encoding="UTF-8"?>
<user>
  <name>Chiang Mai</name>
</user>
EOS
    end

    it 'includes the result of some method calls on the model with :methods option' do
      user = @user_class.find(1)
      user.to_xml(methods: :permalink).should == <<EOS
<?xml version="1.0" encoding="UTF-8"?>
<user>
  <id type="integer">1</id>
  <name>Chiang Mai</name>
  <age type="integer">16</age>
  <created-at type="dateTime">2015-12-29T16:38:27Z</created-at>
  <permalink>1-chiang-mai</permalink>
</user>
EOS
    end

    it 'includes associations with :include option' do
      post_class = Class.new do
        include ActiveModel::Serializers::Xml
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
        include ActiveModel::Serializers::Xml
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
      user.to_xml(include: :posts).should == <<EOS
<?xml version="1.0" encoding="UTF-8"?>
<user>
  <id type="integer">1</id>
  <name>Chiang Mai</name>
  <age type="integer">16</age>
  <created-at type="dateTime">2015-12-29T16:38:27Z</created-at>
  <posts type="array">
    <post>
      <id type="integer">1</id>
      <author-id type="integer">1</author-id>
      <title>Welcome to the weblog</title>
    </post>
    <post>
      <id type="integer">2</id>
      <author-id type="integer">1</author-id>
      <title>So I was thinking</title>
    </post>
  </posts>
</user>
EOS

      user = @user_class.find(1)
      user.to_xml(
        include: {
          posts: {
            include: {
              comments: { only: :body } },
            only: :title } }
      ).should == <<EOS
<?xml version="1.0" encoding="UTF-8"?>
<user>
  <id type="integer">1</id>
  <name>Chiang Mai</name>
  <age type="integer">16</age>
  <created-at type="dateTime">2015-12-29T16:38:27Z</created-at>
  <posts type="array">
    <post>
      <title>Welcome to the weblog</title>
      <comments type="array">
        <comment>
          <body>1st post!</body>
        </comment>
        <comment>
          <body>Second!</body>
        </comment>
      </comments>
    </post>
    <post>
      <title>So I was thinking</title>
      <comments type="array">
        <comment>
          <body>Don't think too hard</body>
        </comment>
      </comments>
    </post>
  </posts>
</user>
EOS
    end

    describe '#from_xml' do
      before do
        @person_class = Class.new do
          include ActiveModel::Serializers::Xml
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

      it 'sets the model attributes from a XML string' do
        xml = { name: 'bob', age: 22, awesome: true }.to_xml
        person = @person_class.new
        person.from_xml(xml).should == person
        person.name.should == 'bob'
        person.age.should == 22
        person.awesome.should == true
      end
    end
  end
end
