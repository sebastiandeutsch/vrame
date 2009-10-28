module JsonObject
  class SchemaNotFoundError < RuntimeError
  end

  class Store
    include Serializable
    
    attr_reader :errors
    
    def initialize(options = {})
      @values = {}
      @schema = options[:schema] if options[:schema]
      raise SchemaNotFoundError, "Can't initialize a Store without a schema" unless schema.is_a? Schema
    end
    
    def self.load_from_json_with_schema(json, schema)
      raise SchemaNotFoundError, "Can't initialize a Store without a schema" unless schema.is_a?(Schema)

      return self.new(:schema => schema) if json.blank?
      
      store = JSON.parse(json)
      if store.is_a? Store
        store.instance_variable_set(:@schema, schema)
      else
        store = self.new(:schema => schema)
      end
      store
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
      store.instance_variable_set(:@values, object['values'])
      store
    end
    
  private
    
    def read_value(name)
      field = @schema.field_for(name)
      @values[field.uid]
    end
    
    def write_value(name, value)
      name, value = normalize_access_to_object(name, value)
      field = @schema.field_for(name)
      @values[field.uid] = field.value_from_param(value)
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