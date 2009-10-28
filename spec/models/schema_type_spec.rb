require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "A basic", JsonObject::Type, "object" do
  before :each do
    @new_type = JsonObject::Type.new
  end
  
  %w(name description title uid).each do |attribute|
    it "should have a #{attribute} field" do
      @new_type.should respond_to(attribute)
      @new_type.should respond_to("#{attribute}=")

      @new_type.send("#{attribute}=", "xxx")
      @new_type.send(attribute).should eql("xxx")
    end
  end
  
  it "uid should be initialized to a random value on a new Type Instance" do
    @new_type.uid.should_not be_nil
    @new_type.uid.should match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/)
  end
  
  it "should have a to_json method to serialize its representation as a json-'field' object" do
    @new_type.should respond_to(:to_json)
    @new_type.to_json.should match(@new_type.uid)
    @new_type.to_json.should match(/JsonObject::Type/)
  end
  
  it "should serialize all instance variables not explicitly excluded" do
    @new_type.instance_variable_set(:@dfalkm, "whoohoo")
    @new_type.instance_variable_set(:@errors, "rarrr")
    @new_type.to_json.should match(/whoohoo/)
    @new_type.to_json.should_not match(/rarrr/)
  end
  
  it "should not serialize the errors instance variable" do
    @new_type.valid?
    @new_type.to_json.should_not match(/errors/)
  end
  
  it "should have a self.json_create method to deserialize its representation" do
    JsonObject::Type.should respond_to(:json_create)
    @new_type.name = "Name"
    @new_type.description = "Great description"
    json = @new_type.to_json
    revived = JSON.parse(json)
    revived.should be_instance_of(JsonObject::Type)
    revived.uid.should eql @new_type.uid
  end
  
  it "should convert the 'required' field to a Ruby boolean" do
    [true, 1, "1", "true"].each do |val|
      @new_type.required = val
      @new_type.required.should eql(true)
    end
  end

  describe "with validations" do
    it "should provide a 'valid?' method on the Type Instance" do
      @new_type.should respond_to(:valid?)
    end
    
    it "should refuse an empty name" do
      @new_type.should_not be_valid
      @new_type.name = "bla"
      @new_type.should be_valid
    end
    
    it "should refuse a reserved keyword for the types name" do
      @new_type.name = "type"
      @new_type.should_not be_valid        
    end
    
    it "should generate a name from its title" do
      @new_type.title.should be_blank
      @new_type.name.should be_blank
      @new_type.title = "Super-stupid title"
      @new_type.name.should eql("super_stupid_title")
    end
    
    it "should dehumanize names" do
      @new_type.name = "BLA blübb  ß  "
      @new_type.name.should eql("bla_bluebb_ss")
    end
    
    it "should not generate a name if already set" do
      @new_type.title.should be_blank
      @new_type.name.should be_blank
      @new_type.name = "blafoo"
      @new_type.title = "Super-stupid title"
      @new_type.name.should eql("blafoo")
    end
        
    it "should not allow numbers at the beginning of the name" do
      @new_type.name = "blubb"
      @new_type.should be_valid
      @new_type.name = "9elements rulz"
      @new_type.should_not be_valid
    end
    
    it "should not allow _json at the end of the name" do
      @new_type.name = "blubb_json"
      @new_type.should_not be_valid
    end
    
  end
  
  describe "that has been subclassed" do
    it "should execute the validate method in subclasses" do
      @new_type.should_receive(:validate)
      @new_type.valid?
    end
  end
  
end

describe JsonObject::Types::Select do
  before :each do
    @new_select = JsonObject::Types::Select.new
  end
  
  it "should have an options attribute" do
    @new_select.should respond_to(:options)
  end

  it "should remove empty options" do
    @new_select.options = ["Bla", "Blubb", "", nil]
    @new_select.options.should have(2).options
  end
  
  it "should strip options" do
    @new_select.options = ["Bla  ", "  Blubb", "  Blipp  "]
    @new_select.options[0].should eql("Bla")
    @new_select.options[1].should eql("Blubb")
    @new_select.options[2].should eql("Blipp")
  end
  
  it "should not be valid with less that 2 options" do
    @new_select.name = "Blub"
    @new_select.options = ["Bla", "Blubb"]
    @new_select.should be_valid
    @new_select.options = ["Bla"]
    @new_select.should_not be_valid
    @new_select.options = []
    @new_select.should_not be_valid
  end
  
  it "should be possible to allow blank"
  
end

describe JsonObject::Types::MultiSelect do
  before :each do
    @new_multiselect = JsonObject::Types::MultiSelect.new(:options => ['a', 'b', 'c'])
  end
  
  it "should properly validate subsets" do
    @new_multiselect.value_valid?([]).should be_true
    @new_multiselect.value_valid?(['a', 'b']).should be_true
    @new_multiselect.value_valid?(['a', 'b', 'c']).should be_true

    @new_multiselect.value_valid?(['d']).should_not be_true
    @new_multiselect.value_valid?(['a', 'd']).should_not be_true
  end
end

describe JsonObject::Types::Bool do
  before :each do
    @new_bool = JsonObject::Types::Bool.new(:name => 'checkbox')
    @schema = JsonObject::Schema.new
    @schema.fields << @new_bool
    @store = JsonObject::Store.new(:schema => @schema)
  end
  
  it "should convert boolish values to true or false" do
    [true, "true", 1, "1"].each do |v|
      @store.checkbox = v
      @store.checkbox.should be_true
    end
    [false, "bla", nil, "0", 0].each do |v|
      @store.checkbox = v
      @store.checkbox.should be_false
    end
  end
end

