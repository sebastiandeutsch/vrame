module JsonObject
  class UnknownSchemaAttributeError < NoMethodError
  end
  
  class UnknownAssociationError < ActiveRecord::ActiveRecordError
  end
  
  class EmbeddedSchema
    include Serializable
    
    attr_reader :fields, :mappings

    def initialize(hash, options = {})
      @options = self.class.default_options.merge(options)
      
      initialize_mappings
      
      assign(hash)
    end
    
    def field_for(name)
      @fields.fetch(name)
    rescue IndexError
      raise UnknownSchemaAttributeError.new("Attribute named '#{name}' not in store schema")
    end
    
    def has_attribute?(name)
      name = name.to_sym
      @fields.include?(name)
    end
    
    def each(&block)
      @fields.each(block)
    end
    
    def self.default_options
      @@default_options ||= {
        :mappings  => {}
      }
    end
    
    def assign(hash)
      super(hash)
      initialize_fields
    end

  private
    
    def initialize_mappings
      @mappings ||= {}
      
      @options[:mappings].each do |type|
        @mappings[type] = type.constantize
      end
    end
    
    def initialize_fields
      @fields = {}
      
      if @hash['fields'].is_a? Array
        @hash['fields'].each do |field|
          @fields[field['name']] = Field.new(field, self)
        end
      end
    end
    
  end
  
  class Schema < EmbeddedSchema
    def initialize(name, instance, options)
      @name     = name
      @instance = instance
      @options  = options
      
      initialize_serialization
      
      super(@hash, options)
    end
  end
end

require 'jsonobject/schema/field'

