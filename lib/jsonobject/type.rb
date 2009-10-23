module JsonObject
    # A Type
    #
    #  - Determines the look of the category editor for its field
    #  - Determines how the data from the category editor are stored in the schema
    #  - Validates Fields
    #    - Prevents use of reserved keywords
    #    - Prevents use of duplicate names
    #    - Prevents illegal configuration of types
    #
    #  The Type's configuration data from the schema is used to form an instance of
    #  the type. This instance
    #   - Validates data entered in the document editor
    #   - Determines the look of the document editor
    #   - Determines how the params hash from the editor is converted to a Ruby data structure
    #   - Determines how that Ruby data strucute is serialized/deserialized
    #     Type.serialize(ruby object)      => Primitivobjekt
    #     Type.deserialize(primitivobjekt) => Ruby Object
    class Type
      RESERVED_KEYWORDS = Object.new.methods
      UNSERIALIZABLE_PROPERTIES = ['@errors']

      attr_accessor :name, :description, :title, :required, :uid
      
      def initialize
        self.uid = generate_uid
        
      end
      
      def generate_uid
        # @TODO Only works with MySQL
        ActiveRecord::Base.connection.select_value("SELECT UUID();")
      end
      
      def valid?
        @errors = []
        validate_base
        @errors.empty?
      end
      
      def title=(t)
        @title = t
        self.name = t if name.blank?
      end
      
      def name=(n)
        @name = JsonObject::Helper.dehumanize(n)
      end
      
      def to_json
        hash = {}
        self.instance_variables.each do |attr|
          next if UNSERIALIZABLE_PROPERTIES.include?(attr)
          hash[attr[1..-1]] = self.instance_variable_get(attr)
        end
        hash[:json_class] = self.class.name
        hash.to_json
      end
      
      def self.json_create(object)
        type = self.allocate
        object.delete("json_class")
        object.each do |key, value|
          type.instance_variable_set("@#{key}", value)
        end
        type
      end
      
    private
    
      def validate_base
        @errors << [:name, "darf nicht leer sein"] if name.blank?
        @errors << [:name, "darf kein reserviertes Wort sein"] if RESERVED_KEYWORDS.include?(name)
        @errors << [:name, "darf nicht mit einer Zahl beginnen"] if name =~ /^\d/
      end
    end
end