module JsonObject
  class UnknownSchemaAttributeError < NoMethodError
  end
  
  class UnknownAssociationError < ActiveRecord::ActiveRecordError
  end
  
  class EmbeddedSchema
    include Serializable
    
    def self.default_options
      @@default_options ||= {
        :mappings  => {}
      }
    end
    
    attr_reader :mappings
    
    def initialize(hash, options = {})
      @options = self.class.default_options.merge(options)
      
      assign(hash)
      
      initialize_mappings
    end
    
    def assign(hash)
      super(hash)
      
      initialize_fields
    end
    
    def find_field_by_name(name)
      begin
        @name_field_map.fetch(name)
      rescue IndexError
        raise UnknownSchemaAttributeError.new("Attribute named '#{name}' not in store schema")
      end
    end
    
    def has_attribute?(name)
      name = name.to_sym
      @name_field_map.include?(name)
    end
    
    def each(&block)
      @schema_fields ||= {}
      if @hash.include?('fields')
        @hash['fields'].each do |field|
          yield @schema_fields[field['name']] ||= SchemaField.new(field)
        end
      end
    end
    
  private
  
    def initialize_mappings
      @mappings ||= {}
    
      @options[:mappings].each do |k, v|
        @mappings[k.to_s.camelize] = v.to_s.classify.constantize
      end
    end
    
    def initialize_fields
      # Initialize empty name->field map
      @name_field_map = {}
      
      if @hash.include?('fields')
        @hash['fields'].each do |field|
          # Assign UID if necessary
          field['uid'] ||= next_uid
          
          # Generate attribute title if there is none (only if there's a title)
          if field['name'].nil? and not field['title'].nil?
            field['name'] = Helper.dehumanize(field['title'])
          end
          
          # Assign name->field mapping
          @name_field_map[field['name']] = field
        end
      end      
    end
    
    def next_uid
      # Find highest uid of fields
      @last_uid ||= @hash['fields'].map { |field| field['uid'].to_i }.max || 0

      # Increase last UID
      (@last_uid += 1).to_s
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
  
  class SchemaField < OpenStruct
    def type
      @table[:type]
    end
  end
end