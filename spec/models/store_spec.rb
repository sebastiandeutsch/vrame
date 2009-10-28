require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe JsonObject::Store do
  # Json store ist deklariert in Document
  #   dort steht wie der store heisst und wo das schema liegt, relativ zum dokument
  # 
  # Store selbst cached das Schema
  #   enthält aber sonst keinerlei Konfiguration, nur die daten in "values"
  # Serializer kann dann Fields (schema) und Values (store) kombinieren
  
  it "should have a 'schema' accessor" do
    JsonObject::Store.new(:schema => JsonObject::Schema.new).should respond_to(:schema)
  end

  it "should generate a blank Store if json_deserialization fails"

  
  it "should not allow initialization without a Schema" do
    lambda{JsonObject::Store.new}.should raise_error(JsonObject::SchemaNotFoundError)
    lambda{JsonObject::Store.new(:schema => JsonObject::Schema.new)}.should_not raise_error(JsonObject::SchemaNotFoundError)
  end
  
  it "the schema accessor should throw an exception if the schema can't be found" do
    store = JsonObject::Store.new(:schema => JsonObject::Schema.new)
    store.instance_variable_set(:@schema, nil)
    lambda{store.schema}.should raise_error(JsonObject::SchemaNotFoundError)
  end
  
  it "should let the schema be set through the schema option in the constructor" do
    store = JsonObject::Store.new(:schema => JsonObject::Schema.new)
    store.schema.should be_instance_of(JsonObject::Schema)    
  end
  
  describe "with a schema" do
    before :each do
      @schema = JsonObject::Schema.new
      @schema.fields << JsonObject::Types::String.new(:title => "Headline", :required => true)
      @schema.fields << JsonObject::Types::Text.new(:title => "Article")
      @store  = JsonObject::Store.new(:schema => @schema)
    end
    
    it "should allow writing of attributes defined in the schema" do
      @store.headline = "Whoopeedoopee"
    end

    it "should allow reading of attributes defined in the schema" do
      @store.headline = "Whoopeedoopee"
      @store.article  = "Yay"
      @store.headline.should eql("Whoopeedoopee")
      @store.article.should  eql("Yay")
    end
    
    it "should disallow writing of attributes not defined in the schema" do
      lambda{@store.blargl = "Whoopeedoopee"}.should raise_error(JsonObject::UnknownSchemaAttributeError)
    end
    
    it "should raise an exception when trying to access an unknown attribute" do
      lambda{@store.blargl}.should raise_error(JsonObject::UnknownSchemaAttributeError)
    end
    
    it "should return nil when accessing an unset attribute" do
      @store.headline.should be_nil
    end
    
    it "should have an update method" do
      @store.should respond_to(:update)
      
      @store.update(@schema.fields[0].uid => "Uberschrift",
                    @schema.fields[1].uid => "Artikeltext")
      @store.headline.should eql("Uberschrift")
      @store.article.should eql("Artikeltext")
    end

    it "should throw an error if updating invalid uids" do
      lambda{@store.update("asdasdasd" => "Uberschrift")}.should raise_error(JsonObject::UnknownSchemaAttributeError)
    end
    
    it "should validate itself by validating the types" do
      @store.should respond_to(:valid?)
      @store.should_not be_valid
      @store.headline = "bla"
      @store.should be_valid
      
      @store.schema.fields << JsonObject::Types::Select.new(:name => "auswahl", :options => ["Bla", "Blubb"])
      @store.auswahl = "Bla"
      @store.should be_valid

      @store.auswahl = "asdasd"
      @store.should_not be_valid
    end
    
    it "should serialize itself to json" do
      @store.should respond_to(:to_json)
      @store.headline = "ueberschrift"
      @store.to_json.should match(/ueberschrift/)
    end
    
    it "should deserialize itself from json" do
      @schema = JsonObject::Schema.new
      @schema.fields << JsonObject::Types::String.new(:title => "Headline", :required => true)
      @schema.fields << JsonObject::Types::Text.new(:title => "Article")
      @store  = JsonObject::Store.new(:schema => @schema)
      @store.headline = "aaa"
      @store.article  = "bbb"
      
      @re_store = JsonObject::Store.load_from_json_with_schema(@store.to_json, @schema)
      @re_store.should be_instance_of(JsonObject::Store)
      @re_store.schema.field_for('headline').should be_instance_of(JsonObject::Types::String)
      @re_store.schema.fields[1].name.should eql('article')
      @re_store.headline.should eql('aaa')
      @re_store.article.should eql('bbb')
    end

    it "should not allow deserialization without a Schema" do
      @schema = JsonObject::Schema.new
      @schema.fields << JsonObject::Types::String.new(:title => "Headline", :required => true)
      @schema.fields << JsonObject::Types::Text.new(:title => "Article")
      @store  = JsonObject::Store.new(:schema => @schema)
      @store.headline = "aaa"
      @store.article  = "bbb"
      
      lambda{JsonObject::Store.load_from_json_with_schema(@store.to_json)}.should raise_error(ArgumentError)
      lambda{JsonObject::Store.load_from_json_with_schema(@store.to_json, nil)}.should raise_error(JsonObject::SchemaNotFoundError)
    end

  end

end