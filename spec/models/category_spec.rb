require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Category, :type => :model do
  
  before(:all) do
    @title              = "JsonObjectTesting"
    @without_meta_title = "JsonObjectTestingWithoutTitle"
    
    @schema_fields = [
      # Simple values
      { "name" => "some_string",      "type" => "JsonObject::Types::String"     },
      { "name" => "some_text",        "type" => "JsonObject::Types::Text"       },
      
      # # Mapped ActiveRecord pointers
      # {               "name" => "some_asset",       "type" => "JsonObject::Types::Asset"      },
      # {               "name" => "some_collection",  "type" => "JsonObject::Types::Collection" },
      # 
      # # More of the above
      # { "uid" => "3", "name" => "another_text",     "type" => "JsonObject::Types::Text"       },
      # {               "name" => "yet_another_text", "type" => "JsonObject::Types::Text"       },
      # {               "name" => "another_asset",    "type" => "JsonObject::Types::Asset"      },          
      # 
      # # Mapped/serialized object values
      # {               "name" => "some_date",        "type" => "JsonObject::Types::Date"       },
      # {               "name" => "some_time",        "type" => "JsonObject::Types::Time"       },
      # {               "name" => "some_datetime",    "type" => "JsonObject::Types::DateTime"   },
      
      # Field without name but with title
      { "title" => "Some Title",      "type" => "JsonObject::Types::String"     }
    ]
  end
  
  before(:each) do
    @category = Category.new(:title => @title, :schema => @schema_fields)
  end
  
  it "should satisfy meta attribute object identity" do
    @category.schema.should equal(@category.schema)
  end
  
  it "should serialize the meta object via JSON" do
    @category.save
    
    @category = Category.find_by_title(@title)
    @category.schema.should be_instance_of JsonObject::Schema
    @category.schema.should have(@schema_fields.length).fields
    @category.schema.fields[0].name.should eql('some_string')
    @category.schema.fields[1].name.should eql('some_text')
  end
  
  describe "meta" do
    before :each do
      pending("Store crap")
    end

  
  it "should have a meta attribute with readable attribtues" do
    @category.meta.some_string.should  == "Hello, I'm a value for a field called some_string!"
    @category.meta.some_text.should    == "Hello, I'm a value for a field called some_text!"
    @category.meta.another_text.should == "Hello, I'm a value for a field called another_text!"
  end
  
  it "should have a meta attribute with accessible attributes" do
    @category.meta.some_string      = "Modified value for some_string"
    @category.meta.another_text     = "Modified value for another_text"
    @category.meta.yet_another_text = "Modified value for yet_another_text"
    @category.meta.some_text        = "Modified value for some_text"
    
    @category.meta.some_string.should      == "Modified value for some_string"
    @category.meta.another_text.should     == "Modified value for another_text"
    @category.meta.yet_another_text.should == "Modified value for yet_another_text"
    @category.meta.some_text.should        == "Modified value for some_text"
  end
  
  it "should save a modified meta attribute correctly" do
    @category.meta.some_string      = "Modified value for some_string"
    @category.meta.another_text     = "Modified value for another_text"
    @category.meta.yet_another_text = "Modified value for yet_another_text"
    @category.meta.some_text        = "Modified value for some_text"
    
    @category.save
    
    @category = Category.find_by_title(@title)
    
    @category.meta.some_string.should      == "Modified value for some_string"
    @category.meta.another_text.should     == "Modified value for another_text"
    @category.meta.yet_another_text.should == "Modified value for yet_another_text"
    @category.meta.some_text.should        == "Modified value for some_text"
  end
  
  it "should have a meta attribute which raises an error when trying to access an unknown attribute" do
    lambda {
      @category.meta.unknown_schema_attribute
    }.should raise_error(JsonObject::UnknownSchemaAttributeError)    
    
    lambda {
      @category.meta.unknown_schema_attribute = "I don't have a place in this world"
    }.should raise_error(JsonObject::UnknownSchemaAttributeError)
  end
  
  it "should have a meta attribute which maps typed fields without values to nil" do
    @category.meta.some_asset.should      == nil
    @category.meta.some_collection.should == nil
    @category.meta.some_date.should       == nil
  end
  
  it "should have a meta attribute which maps and serializes an asset attribute correctly" do
    @category.save
    
    asset = @category.assets.create()
    
    @category.meta.another_asset = asset
    
    @category.save
    
    @category = Category.find_by_title(@title)
    
    @category.meta.another_asset.should == asset
  end
  
  it "should have a meta attribute which maps and serializes a date attribute correctly" do
    date = Date.today
    
    @category.meta.some_date = date
    
    @category.save
    
    @category = Category.find_by_title(@title)
    
    @category.meta.some_date.should == date
  end
  
  it "should have a meta attribute which populates a field's attribute name from its title if the attribute name was empty" do
    @category.meta.some_title.should == "Hello, I should be accesible via an attribute altough i only had a title defined!"
  end
  
  end
end
