module JsonObject
  class SchemaNotFoundError < RuntimeError
  end

  class Store
    include Serializable
    
    attr_reader :errors
    
    def initialize(options = {})
      @values = {}
      self.schema = options[:schema] if options[:schema]
    end
    
    def schema=(s)
      @schema = s
    end
    
    def schema
      raise SchemaNotFoundError unless @schema.is_a?(JsonObject::Schema)
      @schema
    end
    
    def update(hash)
      hash.each_pair do |uid, value|
        field = @schema.field_by_uid(uid)
        @values[field.uid] = value
      end
    end
    
    def valid?
      @errors = []
      @schema.fields.each do |field|
        @errors << [field.name, field.value_errors] unless field.value_valid?(@values[field.uid])
      end
      @errors.empty?
    end
    
    def method_missing(name, value=nil)
      name = name.to_s
      unless name[-1,1] == '='
        read_value(name)
      else
        write_value(name.chop, value)
      end
    end
    
    def to_json(*args)
      {:json_class => self.class.name,
       :values     => @values}.to_json(*args)
    end
    
    def self.json_create(object)
      store = self.allocate
      store.instance_variable_set(:@values, object.values)
      store
    end
    
  private
    
    def read_value(name)
      field = @schema.field_for(name)
      @values[field.uid]
    end
    
    def write_value(name, value)
      field = @schema.field_for(name)
      name, value = normalize_access_to_object(name, value)
      @values[field.uid] = value
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