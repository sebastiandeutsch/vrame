require 'jsonobject/helper'
require 'jsonobject/schema'
require 'jsonobject/store'
require 'jsonobject/type'
require 'jsonobject/types'


# = JsonObject
#  
# The JSONObject is a collection of classes that provide mechanisms to save
# structured data in a typed, Hash-like collection (the Store), defined by a
# Schema. It consists of the following parts:
#  
# [JsonObject] Contains mechanisms to extend ActiveRecord models with
#              Stores/Schemas. The JsonObject itself doesn't contain anything
#              interesting. See JsonObject:ClassMethods for more information.
# [JsonObject::Schema] A Schema that defines which types of data can be saved
#                      in a Store, how the fields, should be named, wether
#                      they're required etc.
# [JsonObject::Store] A datastore that is linked to a Schema describing its
#                     contents.
# [JsonObject::Type] The definition of a field, containing type casting TODO
#                    Subclass this to define new types. Some common types
#                    are already predefined in JsonObject::Types.
# 
# TODO: Accessing the Data in a form

module JsonObject # @TODO rename JsonObjectExtension, this is not an object!
  
  class InvalidSchemaPath < RuntimeError
    #TODO More descriptive
  end
  
  class << self
    def included base # :nodoc:
      base.extend(ClassMethods)
    end
  end

  # Contains class methods that are added to ActiveRecord model classes
  #   
  # To extend an ActiveRecord model with JSONObject functionality provide
  # <schemaname>_json and <storename>_json attributes in your classes and use
  # the has_json_schema / has_json_store methods.
  #   
  # In the following example the store name is simply "store", the schema name
  # is "schema".
  #   
  #   class Category < ActiveRecord::Base
  #     has_many :documents
  #     has_json_schema :schema
  #
  #     ...
  #   
  #   end
  #   
  #   class Document < ActiveRecord::Base
  #     belongs_to :category
  #     has_json_store :store, :schema => [:category, :schema]
  #
  #     ...
  #   
  #   end
  #
  # This makes available a +schema+ attribute on every category and a +store+
  # attribute on every document. The <tt>:schema</tt> option to the has_json_store
  # declaration is required and points the store to its schema.
  # It is evaluated by subsequently calling the methods in the array on the
  # document instance, in this case leading to the document's category and the
  # category's schema attribute.
  module ClassMethods
    def has_json_schema(name, options = {})
      include InstanceMethods
      
      json_schema_options[name] = options
      
      define_method name do |*args|
        json_schema_for(name)
      end
      
      define_method "#{name}=" do |hash|
        json_schema_for(name).update(hash)
      end
      
      before_save do |instance|
        instance["#{name}_json"] = instance.json_schema_for(name).to_json
      end
    end
    
    def has_json_store(name, options = {})
      include InstanceMethods
      
      raise InvalidSchemaPath unless options.has_key?(:schema)
      
      json_store_options[name] = options
      
      define_method name do |*args|
        json_store_for(name)
      end
      
      define_method "#{name}=" do |hash|
        json_store_for(name).update(hash)
      end

      before_save do |instance|
        instance["#{name}_json"] = instance.json_store_for(name).to_json
      end
    end
    
    # Access the options for declared Schemas in an inheritable attribute
    def json_schema_options # :nodoc:
      if read_inheritable_attribute(:json_schema_options).nil?
        write_inheritable_attribute(:json_schema_options, {})
      end
      read_inheritable_attribute(:json_schema_options)
    end
    
    # Access the options for declared Stores in an inheritable attribute
    def json_store_options # :nodoc:
      if read_inheritable_attribute(:json_store_options).nil?
        write_inheritable_attribute(:json_store_options, {})
      end
      read_inheritable_attribute(:json_store_options)
    end
  end
  
  module InstanceMethods # :nodoc:
    
    # Accessor for the instantiated JsonSchemas
    def json_schemas
      @json_schemas ||= {}
    end
    
    # Accessor for the instantiated JsonStores
    def json_stores
      @json_stores ||= {}
    end
    
    # Access a Schema by its name, loading it form JSON if it hasn't been accessed before.
    def json_schema_for(name)
      json_schemas[name] ||= initialize_schema(name, self.class.json_schema_options[name])
    end
    
    # Access a Store by its name, loading it form JSON if it hasn't been accessed before.
    def json_store_for(name)
      json_stores[name] ||= initialize_store(name, self.class.json_store_options[name][:schema])
    end
  
  private
    
    def initialize_schema(name, options)
      json   = self["#{name}_json"]
      Schema.load_from_json_with_options(json, options)
    end

    def initialize_store(name, schema_path)
     json  = self["#{name}_json"]
     schema = schema_from_path(schema_path)
     Store.load_from_json_with_schema(json, schema)
    end

    # Follow a schema path to find a schema for a store
    def schema_from_path(schema_path)
      schema_path = [schema_path].flatten
      raise InvalidSchemaPath if schema_path.compact.empty?
      schema = schema_path.inject(self) { |current, attr| current.send(attr) }
      schema or raise JsonObject::SchemaNotFound, "Schema_path #{schema_path.join('.')} does not lead to a schema"
    end
  end
end

if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, JsonObject)
end