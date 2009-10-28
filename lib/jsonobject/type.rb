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
      attr_reader   :errors
      
      def initialize(params={})
        update_attributes(params)
        self.uid = generate_uid if self.uid.blank?
        self.name = self.title if self.name.blank? && !self.title.blank?
      end
      
      def generate_uid
        # @TODO Only works with MySQL
        ActiveRecord::Base.connection.select_value("SELECT UUID();")
      end
      
      def valid?
        @errors = []
        validate_base
        validate if self.respond_to?(:validate)
        @errors.empty?
      end
      
      def title=(t)
        @title = t
        self.name = t if name.blank?
      end
      
      def name=(n)
        @name = JsonObject::Helper.dehumanize(n)
      end
      
      def required=(r)
        @required = [true, "true", 1, "1"].include?(r)
      end
      
      def to_json(*args)
        hash = {}
        self.instance_variables.each do |attr|
          next if UNSERIALIZABLE_PROPERTIES.include?(attr)
          hash[attr[1..-1]] = self.instance_variable_get(attr)
        end
        hash[:json_class] = self.class.name
        hash.to_json(*args)
      end
      
      def self.json_create(object)
        type = self.allocate
        object.delete("json_class")
        type.update_attributes(object)
        type
      end
      
      def update_attributes(hash)
        hash.each do |key, value|
          self.instance_variable_set("@#{key}", value)
        end
      end
      
      def value_from_param(param)
        param
      end

      def value_valid?(v)
        @value_errors = []
        validate_value_base(v)
        validate_value(v) if self.respond_to?(:validate_value)
        @value_errors.empty?
      end
      
      attr_reader :value_errors
      
    private
      
      def validate_value_base(v)
        @value_errors << ["is required and can not be blank"] if v.blank? && required
      end
      
      def validate_base
        @errors << [:name, "darf nicht leer sein"] if name.blank?
        @errors << [:name, "darf nicht auf _json enden"] if name =~ /_json$/
        @errors << [:name, "darf kein reserviertes Wort sein"] if RESERVED_KEYWORDS.include?(name)
        @errors << [:name, "darf nicht mit einer Zahl beginnen"] if name =~ /^\d/
      end
    end
end