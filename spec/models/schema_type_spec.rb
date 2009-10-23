require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "A basic", JsonObject::Type, "object" do
  before :each do
    @new_type = JsonObject::Type.new
  end
  
  %w(name description title required uid).each do |attribute|
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
    
    it "should refuse duplicate names" do
      pending("Implemented later, type needs to be integrated with Schema")
    end
    
  end
  
  describe "that has been subclassed" do
    it "should execute the validate method in subclasses and respect their additions to the error object"

    it "should prevent illegal configuration of types" do
      pending("Implemented by concrete types")
    end
  end
  
end

describe JsonObject::Types::String do
  
end
