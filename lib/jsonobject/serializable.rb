module JsonObject
  module Serializable
    def initialize_serialization
      # Decode JSON string from database into object
      if @instance.query_attribute(column_name)
        assign(ActiveSupport::JSON.decode(@instance.read_attribute(column_name)))
      else
        assign(@instance.read_attribute(@name) || {})
      end
      
      # Encode object into JSON string for database
      @instance.class.before_save do
        @instance.write_attribute(column_name, to_json)
      end
    end
    
    # Decode hash into object
    def assign(hash)      
      @hash = hash
      @hash.default = Hash.new
    end
    
    # Encode object hash to JSON string
    def to_json
      @hash.to_json
    end
    
    private
    
    def column_name
      "#{@name}_json"
    end
  end
end