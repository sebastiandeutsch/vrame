require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Document do
  before(:all) do
    @title = "JsonObjectTesting"
    
    @schema_fields = [
      { "name"  => "some_string",    "type" => "JsonObject::Types::String"     },
      { "name"  => "some_text",      "type" => "JsonObject::Types::Text"       },
      { "title" => "Some Title   ",  "type" => "JsonObject::Types::String"     },
      
      # { "name" => "some_asset",      "type" => "JsonObject::Types::Asset"      },
      # { "name" => "some_collection", "type" => "JsonObject::Types::Collection" },
      # { "name" => "some_date",       "type" => "JsonObject::Types::Date"       }
    ]
  end
  
  describe "meta" do
    before :each do
      @category = Category.create(:title => @title, :schema => @schema_fields)
      
      store_params = {
        @category.schema.field_for('some_string').uid => "Hello, I'm a value for a field called some_string!",
        @category.schema.field_for('some_text').uid   => "Hello, I'm a value for a field called some_text!",
      }
      
      @document = Document.create(:category => @category, :title => @title, :meta => store_params)
    end
    
    it "should have readable attribtues" do
      @document.meta.some_string.should eql("Hello, I'm a value for a field called some_string!")
      @document.meta.some_text.should   eql("Hello, I'm a value for a field called some_text!")
    end
    
    it "should save and restore correctly" do
      @document.meta.some_string = "Modified value for some_string"
      @document.meta.some_text   = "Modified value for some_text"
    
      @document.save
      @document = Document.find_by_title(@title)
    
      @document.meta.some_string.should eql("Modified value for some_string")
      @document.meta.some_text.should   eql("Modified value for some_text")
    end
    
    it "should prohibit access to unknown attributes" do
      lambda {
        @document.meta.meta.unknown_schema_attribute
      }.should raise_error(JsonObject::UnknownSchemaAttributeError)
      
      lambda {
        @document.meta.unknown_schema_attribute = "I don't have a place in this world"
      }.should raise_error(JsonObject::UnknownSchemaAttributeError)
    end
    
    it "should map typed fields without values to nil" do
      pending("Type implementation")
      
      @document.meta.some_string.should     be_nil
      @document.meta.some_text.should       be_nil
      @document.meta.some_title.should      be_nil
      @document.meta.some_asset.should      be_nil
      @document.meta.some_collection.should be_nil
      @document.meta.some_date.should       be_nil
    end
    
    it "should map and serialize an asset attribute correctly" do
      pending("Type implementation")
          
      asset = @category.assets.create()
      
      @document.meta.another_asset = asset
      @document.save
      
      @document = Document.find_by_title(@title)
      @document.meta.another_asset.should eql(asset)
    end
    
    it "should map and serialize a date attribute correctly" do
      pending("Type implementation")
      
      date = Date.today
      
      @document.meta.some_date = date
      @document.save
      
      @document = Document.find_by_title(@title)
      @document.meta.some_date.should eql(date)
    end
    
    it "should populate a field's attribute name from its title if the attribute name was empty" do
      @document.meta.some_title = "Hello, I should be accesible via an attribute altough i only had a title defined!"
      @document.meta.some_title.should eql("Hello, I should be accesible via an attribute altough i only had a title defined!")
    end
  end
end