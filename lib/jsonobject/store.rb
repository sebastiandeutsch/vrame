module JsonObject
  class Store
    include Serializable
    
    def self.default_options
      @@default_options ||= {
        :schema => nil,
        :mappings  => {}
      }
    end
    
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
          unless @hash['schema'].nil?
            EmbeddedSchema.new(@hash['schema'], { :mappings => @options[:mappings] })
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
      
      # Read value from hash
      value = @hash.fetch('values', {}).fetch(field['uid'], nil)
      
      # If field type has a mapping
      if klass = @schema.mappings[type]
        # If field type is a model
        if klass.ancestors.include?(ActiveRecord::Base)
          # Check whether @instance has a has_many association for klass
          association_name = klass.to_s.tableize.to_sym
          unless reflection = @instance.class.reflect_on_association(association_name) and reflection.macro == :has_many
            raise UnknownAssociationError.new("#{@instance.class} has no has_many association '#{association_name.to_s}'")
          end
          association_proxy = @instance.send(reflection.name)
                    
          # Try to find model instance with id=value
          begin
            association_proxy.find(value.to_i)
          # Create new model instance
          rescue ActiveRecord::RecordNotFound
            association_proxy.build
          end
        # If field type is a normal class
        else
          # If decoded object has wrong type
          if value.class != klass and not value.nil?
            # Raise error
            raise TypeError.new("Decoded object's class '#{value.class}' doesn't match schema's class '#{klass}'")
          else
            # Return plain decoded object
            value
          end
        end
      # If field type has no mapping
      else
        # Return plain value
        value
      end
    end
    
    def write_value(name, value)
      # Check whether name is already JSON encoded
      if match = name.match(/(.*)_json$/)
        name = match[1]
        already_encoded = true        
      else
        already_encoded = false
      end
      
      # Get field information from schema
      field = @schema.find_field_by_name(name)
      type  = field['type']
      
      # If field type has a mapping
      if klass = @schema.mappings[type]
        # If field type is a model
        if klass.ancestors.include?(ActiveRecord::Base)
          # Save model instance id
          value = value.id
        # If field type is a normal class
        else
          # Decode value if already JSON encoded
          value = JSON.parse(value) if already_encoded
        end
      end
            
      # Write value into hash
      @hash['values'][field['uid']] = value
    end
  end
end