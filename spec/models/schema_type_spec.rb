require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe JsonObject::Type do
  describe "common functionality" do
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
    
    describe "uid" do
      it "should be initialized to a random value on a new Type Instance" do
        @new_type.uid.should_not be_nil
        @new_type.uid.should match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/)
      end
      it "should be persisted bla keine ahnung"
    end
    
    it "should have a to_json method to serialize its representation as a json-'field' object" do
      @new_type.should respond_to(:to_json)
      @new_type.to_json.should match(@new_type.uid)
      @new_type.to_json.should match(/JsonObject::Type/)
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

    it "should refuse a reserved keyword for the types name"
    it "should generate a name from its title"
    it "should refuse duplicate names"
    it "should prevent illegal configuration of types"    
  end
  
  describe JsonObject::Types::String do
    
  end
end
