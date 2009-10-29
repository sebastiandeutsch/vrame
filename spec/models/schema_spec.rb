require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe JsonObject::Schema do
  
  before :all do
    @schema_params = [{
                 "name"  => "asdf",
                 "title" => "asdf",
                 "type"  => "JsonObject::Types::String",
                 "description" => "oahnz zwoah gsuffe1",
                 "required"    => "0"
               }.freeze,
               {
                 "name" =>"neu",
                 "title" =>"neu",
                 "type" =>"JsonObject::Types::Text",
                 "description" =>"oahnz zwoah gsuffe2",
                 "required" =>"0"
               }.freeze,
               {
                 "name" =>"eins",
                 "title" =>"eins",
                 "type" =>"JsonObject::Types::Datetime",
                 "description" =>"",
                 "required" =>"0"
               }.freeze,
              {
                 "name" =>"fuenf",
                 "options" =>["a", "b", "c", ""],
                 "title" =>"fünf",
                 "type" =>"JsonObject::Types::Select",
                 "description" =>"",
                 "required" =>"0"
               }.freeze].freeze
  end
  
  it "should generate a blank Schema if json_deserialization fails"
  
  it "should provide a update method that accepts the params hash" do
    JsonObject::Schema.new.should respond_to(:update)
  end
  
  describe "when validating with 'valid?" do
    before :each do
      @schema = JsonObject::Schema.new
      @schema.update(@schema_params)
    end
    
    it "should validate all the types" do
      @schema.fields[0].should_receive(:valid?)
      @schema.valid?
    end
    
    it "should validate that no duplicate names are used" do
      @schema.should be_valid
      @schema.fields[1].name = "asdf"
      @schema.should_not be_valid
    end

    it "should validate that no duplicate uids are used" do
      @schema.should be_valid
      @schema.fields[1].uid = @schema.fields[0].uid
      @schema.should_not be_valid
    end
  end
  
  describe "when creating a category" do
    before :each do
      @schema = JsonObject::Schema.new
    end
    
    it "should initialize Types according to the params" do
      @schema.update(@schema_params)
      @schema.field_for("asdf").should be_instance_of(JsonObject::Types::String)
      @schema.field_for("asdf").title.should eql("asdf")
      @schema.field_for("neu").should be_instance_of(JsonObject::Types::Text)
      @schema.field_for("eins").should be_instance_of(JsonObject::Types::Datetime)
      @schema.field_for("fuenf").should be_instance_of(JsonObject::Types::Select)
    end
    
    it "should provide the subscript operator" do
      @schema.update(@schema_params)
      @schema['asdf'].should equal(@schema.field_for('asdf'))
    end
    
    it "should provide has_field? information" do
      @schema.update(@schema_params)
      @schema.should have_field("asdf")
      @schema.should_not have_field("asdfasdasd")
    end
    
    it "should create new uids in the types" do
      @schema.update([{
                   "name"  => "asdf",
                   "title" => "asdf",
                   "type"  => "JsonObject::Types::String",
                   "description" => "oahnz zwoah gsuffe1",
                   "required"    => "0"
                 }])
      @schema.field_for("asdf").uid.should_not be_blank
      @schema.field_for("asdf").uid.should match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/)
    end
    
    describe "and saving it" do
      it "should be converted to json and do this recursively with the types" do
        @schema.update([{
                     "name"  => "asdf",
                     "title" => "asdf",
                     "type"  => "JsonObject::Types::String",
                     "description" => "oahnz zwoah gsuffe1",
                     "required"    => "0"
                   }])
        @schema.field_for("asdf").should_receive(:to_json)
        @schema.to_json
      end
    end
  end

  describe "when loading" do
    before :each do 
      @schema = JsonObject::Schema.new
      @schema.update(@schema_params)
      @json = @schema.to_json
      @loaded_schema = JsonObject::Schema.load_from_json_with_options(@json)
    end
    
    it "should provide a json_create method" do
      JsonObject::Schema.should respond_to(:json_create)
    end
    
    it "should instantiate a schema and its types recursively" do
      @loaded_schema.should be_instance_of(JsonObject::Schema)
      @loaded_schema.fields.should have(4).fields
      @loaded_schema.field_for('asdf').should be_instance_of(JsonObject::Types::String)
    end
    
    it "should recreate its options through the set_options method" do
      @loaded_schema = JsonObject::Schema.load_from_json_with_options(@json, :allowed_types => [JsonObject::Types::String])
      @loaded_schema.instance_variable_get(:@options)[:allowed_types].should have(1).element
    end
  end
  
  describe "when adding a field to a category" do
    before :each do
      @schema = JsonObject::Schema.new
      @schema.update([{
                   "name"  => "asdf",
                   "title" => "asdf",
                   "type"  => "JsonObject::Types::String",
                   "description" => "oahnz zwoah gsuffe1",
                   "required"    => "0"
                 }])
    end
    
    it "should only add fields without a uid" do
      old_uid = @schema.field_for('asdf').uid
      @schema.update([{
                   "name"  => "asdf",
                   "title" => "asdf",
                   "type"  => "JsonObject::Types::String",
                   "description" => "oahnz zwoah gsuffe1",
                   "required"    => "0",
                   "uid" => old_uid
                 },
                 {
                  "name"  => "asdf",
                  "title" => "asdf",
                  "type"  => "JsonObject::Types::String",
                  "description" => "oahnz zwoah gsuffe1",
                  "required"    => "0"
                }])
      @schema.fields.should have(2).fields
    end
    
    it "should give this field a uid and name" do
      old_uid = @schema.field_for('asdf').uid
      @schema.update([{
                   "name"  => "asdf",
                   "title" => "asdf",
                   "type"  => "JsonObject::Types::String",
                   "description" => "oahnz zwoah gsuffe1",
                   "required"    => "0",
                   "uid" => old_uid
                 },
                 {
                  "title" => "Bla Blubb",
                  "type"  => "JsonObject::Types::String"
                }])
      @schema.fields[1].name.should eql("bla_blubb")
      @schema.fields[1].uid.should match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/)
    end
  end
  
  describe "when removing a field from a category" do
    
    before :each do
      @schema = JsonObject::Schema.new
      @schema.update(@schema_params)
      @existing_schema_params = @schema.fields.inject([]) do |memo, field|
        memo + [{"name"  => field.name,
                 "title" => field.title,
                 "type"  => field.class.name,
                 "description" => field.description,
                 "required"    => field.required,
                 "uid" => field.uid }]
      end
    end
    
    it "should recognize the removed field through its absence in the params hash" do
      @schema.fields.should have(4).fields
      @schema.update(@existing_schema_params[0..-2])
      @schema.fields.should have(3).fields
      lambda{@schema.field_for('fuenf')}.should raise_error(JsonObject::UnknownSchemaAttributeError)
      lambda{@schema.field_for('asdf')}.should_not raise_error(JsonObject::UnknownSchemaAttributeError)
    end
  end
  
  describe "when changing a field in a category" do

    before :each do
      @schema = JsonObject::Schema.new
      @schema.update(@schema_params)
      @existing_schema_params = @schema.fields.inject([]) do |memo, field|
        memo + [{"name"  => field.name,
                 "title" => field.title,
                 "type"  => field.class.name,
                 "description" => field.description,
                 "required"    => field.required,
                 "uid" => field.uid }]
      end
    end
    
    it "should find the field in the hash and update it according to the params hash" do
      @existing_schema_params[0]['description'] = "New description"
      @schema.fields.should have(4).fields
      @schema.update(@existing_schema_params)
      @schema.fields.should have(4).fields
      @schema.field_for(@existing_schema_params[0]['name']).description.should eql('New description')
    end
    
    it "should raise an error if trying to change a field with an unknown uid" do
      @existing_schema_params[0]['description'] = "New description"
      @existing_schema_params[0]['uid']         = "123abc"
      @schema.fields.should have(4).fields
      lambda{@schema.update(@existing_schema_params)}.should raise_error(JsonObject::UnknownSchemaAttributeError)
    end
  end
end