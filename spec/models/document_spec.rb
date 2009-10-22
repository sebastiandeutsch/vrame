require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Document, :type => :model do
  before(:all) do
    @title              = "JsonObjectTesting"
    
    @schema_hash = {
      "fields" => [
        { "uid" => "1", "name" => "some_string",      "type" => "String"     },
        { "uid" => "2", "name" => "some_text",        "type" => "Text"       },
        {               "name" => "some_asset",       "type" => "Asset"      }
      ]
    }.freeze
    
    @store_hash = {
      "values" => {
        "1" => "Hello, I'm a value for a field called some_string!",
        "2" => "Hello, I'm a value for a field called some_text!"
      }
    }
  end
  
  before(:each) do
    @category = Category.new(:title => @title, :schema => @schema_hash)
  end
  
  it "should have a meta attribute with accesible attributes using its category's foreign schema" do
    @category.save
        
    @document = Document.new(:category => @category, :title => @title, :meta => @store_hash)
    
    @document.meta.some_string.should == "Hello, I'm a value for a field called some_string!"
    @document.meta.some_text.should   == "Hello, I'm a value for a field called some_text!"
    @document.meta.some_asset.should be_nil
  end
  
end
