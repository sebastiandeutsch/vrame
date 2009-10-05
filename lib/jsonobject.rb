require 'jsonobject/helper'
require 'jsonobject/serializable'
require 'jsonobject/schema'
require 'jsonobject/store'

module JsonObject
  class << self
    def included base
      base.extend(ClassMethods)
    end
  end

  module ClassMethods
    def has_json_schema(name, options = {})
      include InstanceMethods
      
      write_inheritable_attribute(:json_schema_definitions, {}) if json_schema_definitions.nil?
      json_schema_definitions[name] = options
      
      define_method name do |*args|
        json_schema_for(name)
      end
      
      define_method "#{name}=" do |hash|
        json_schema_for(name).assign(hash)
      end
    end
    
    def has_json_store(name, options = {})
      include InstanceMethods
      
      write_inheritable_attribute(:json_store_definitions, {}) if json_store_definitions.nil?      
      json_store_definitions[name] = options
      
      define_method name do |*args|
        json_store_for(name)
      end
      
      define_method "#{name}=" do |hash|
        json_store_for(name).assign(hash)
      end
    end
    
    def json_schema_definitions
      read_inheritable_attribute(:json_schema_definitions)
    end
    
    def json_store_definitions
      read_inheritable_attribute(:json_store_definitions)
    end
  end
  
  module InstanceMethods
    def json_schema_for(name)
      @json_schemas ||= {}
      @json_schemas[name] ||= Schema.new(name, self, self.class.json_schema_definitions[name])
    end
    
    def json_store_for(name)
      @json_stores ||= {}
      @json_stores[name] ||= Store.new(name, self, self.class.json_store_definitions[name])
    end
  end
end

if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, JsonObject)
end