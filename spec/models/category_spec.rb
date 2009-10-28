require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Category do
  
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
  
  before :each do
    @category = Category.new(:title => @title, :schema => @schema_fields)
  end
  
  it "should satisfy schema attribute object identity" do
    @category.schema.should equal(@category.schema)
  end
  
  it "should serialize the schema object via JSON" do
    @category.save
    
    @category = Category.find_by_title(@title)
    @category.schema.should be_instance_of JsonObject::Schema
    @category.schema.should have(@schema_fields.length).fields
    @category.schema.fields[0].name.should eql('some_string')
    @category.schema.fields[1].name.should eql('some_text')
  end
end
