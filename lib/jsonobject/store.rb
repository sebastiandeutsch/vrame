module JsonObject
  class Store
    include Serializable
    
    attr_reader :schema

    def initialize(name, instance, options)
      @name     = name
      @instance = instance
      @options  = self.class.default_options.merge(options)
            
      initialize_serialization
    end
    
    def initialize_schema
      @schema = case @options[:schema]
        when Array then
          [@instance, @options[:schema]].flatten.inject { |current, parent| current.send(parent) }
        when Symbol then
          @instance.send(@options[:schema])
        # when Hash then
        #   EmbeddedSchema.new(@options[:schema], { :mappings => @options[:mappings] })
        else
          unless @hash.nil? or @hash['schema'].nil?
            EmbeddedSchema.new(@hash['schema'], { :allowed_types => @options[:allowed_types] }) # Wieso hier nicht Schema.new?
          end
      end
    end

    def values
      @hash['values']
    end
    
    def method_missing(name, value=nil)
      name = name.to_s
      
      unless name[-1,1] == '='
        read_value(name)
      else
        write_value(name.chop, value)
      end
    end
    
    def self.default_options
      @@default_options ||= {
        :schema => nil,
        :mappings  => {}
      }
    end
    
    def load_hash_from(hash)      
      super(hash)
      initialize_schema
    end
        
  private
    
    def read_value(name)
      field = @schema.field_for(name)
      field.get_value_from_store(self)
    end
    
    def write_value(name, value)
      field = @schema.field_for(name)
      name, value = normalize_access_to_object(name, value)

      field.set_value_in_store(value, self)
    end
    
    def normalize_access_to_object(name,value)
      if name =~ /(.*)_json$/
        name = $1
        value = JSON.parse(value)
      end
      [name, value]
    end
    
  end
end