require 'ostruct'
require 'jsonobject/helper'
require 'jsonobject/schema'
require 'jsonobject/store'
require 'jsonobject/type'
require 'jsonobject/types'

module JsonObject # @TODO rename JsonObjectExtension, this is not an object!
  
  class InvalidSchemaPath < RuntimeError
    #TODO More descriptive
  end
  
  class << self
    def included base
      base.extend(ClassMethods)
    end
  end

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
    
    def json_schema_options
      if read_inheritable_attribute(:json_schema_options).nil?
        write_inheritable_attribute(:json_schema_options, {})
      end
      read_inheritable_attribute(:json_schema_options)
    end
    
    def json_store_options
      if read_inheritable_attribute(:json_store_options).nil?
        write_inheritable_attribute(:json_store_options, {})
      end
      read_inheritable_attribute(:json_store_options)
    end
  end
  
  module InstanceMethods
    
    def json_schemas
      @json_schemas ||= {}
    end
    
    def json_stores
      @json_stores ||= {}
    end
    
    def json_schema_for(name)
      json_schemas[name] ||= initialize_schema(name, self.class.json_schema_options[name])
    end
    
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