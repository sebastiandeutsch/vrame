module JsonObject
  class Store
    include Serializable
    
    def self.default_options
      @default_options ||= {
        :schema => nil,
        :types  => nil
      }
    end
    
    def initialize(name, instance, options)
      @name     = name
      @instance = instance
      @options  = self.class.default_options.merge(options)
            
      initialize_serialization
      initialize_types
    end
    
    def initialize_types
      @types ||= {}
      
      @options[:types].each do |k, v|
        @types[k.to_s.camelize] = v.to_s.classify.constantize
      end
    end
    
    def initialize_schema
      @schema = case @options[:schema].class
        when Array then
          [@instance, @options[:schema]].flatten.inject { |current, parent| current.send(parent) }
        when Symbol then
          @instance.send(@options[:schema])
        when Hash then
          EmbeddedSchema.new(@options[:schema])
        else
          unless @hash['schema'].nil?
            EmbeddedSchema.new(@hash['schema'])
          end
      end
    end
    
    def assign(hash)      
      super(hash)
      
      initialize_schema      
    end
    
    def method_missing(name, value=nil)
      name = name.to_s
      
      unless name[-1,1] == '='
        read_value(name)
      else
        write_value(name.chop, value)
      end
    end
    
  private
    
    def read_value(name)
      # Get field information from schema
      field = @schema.find_field_by_name(name)
      type  = field['type']
      
      # Get value from hash
      value = @hash['values'].fetch(field['uid'], nil)
      
      # If type has mapping class
      if @types.include?(type)
        klass = @types[type]
        
        # If mapping class is a model
        if klass.ancestors.include?(ActiveRecord::Base)
          begin
            klass.find(value.to_i)
          rescue ActiveRecord::RecordNotFound
            klass.new()
          end
        # Return object of type mapping class
        else
          klass.json_create(value)
        end
      # Return plain value
      else
        value
      end
    end
    
    def write_value(name, value)
      value = value.id      if value.is_a? ActiveRecord::Base
      value = value.to_json if @types.values.include?(value.class)
      
      @hash['values'][@schema.find_field_by_name(name)['uid']] = value
    end
  end
end