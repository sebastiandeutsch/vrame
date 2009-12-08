module JsonObject
    # A type, that is, the instance of a subclass of JsonObject::Type describes
    # the fields in a Schema. The roles in the inheritance hierarchy are:
    #
    # Type itself
    # - is more of an abstract class and defines common methods and mechanisms shared by all types.
    # 
    # Each subclass if Type
    # - Determines the kind of options available to the type.
    # - Determines how the data from the category editor is stored in the schema.
    # - Validates itself, its configuration.
    #
    # The Instance of that subclass
    # - Contains the type's configuration (options, name, uid, etc.).
    # - Validates its configuration.
    # - Validates data saved into the corresponding field in the store.
    # - Determines how the params hash from a form is converted to a Ruby
    #   data structure.
    #
    # Predefined Types are contiained in the JsonObject::Types module.
    #
    # == Defining your own types
    # 
    # To declare your own Type, subclass JsonObject::Type. You'll likely have
    # to overwrite the following methods:
    # value_from_param:: Convert forms-data to Ruby objects that are to be stored in the database.
    # object_from_value:: Used to generate return values when accessing the values in the store. You could store an ID in your database and implement this to return a full-fledged ActiveRecord object.
    #
    # and implement
    # [a validate method] (see valid? for a description)
    # [a validate_value method] (see value_valid? for a description)
    # [accessors for the options your type may have] Data from forms you use to configure your types is passed to these (via Schema#update).
    # 
    # Take a look at the sourcecode of the predefined types to get an impression
    # of how to do this.
    class Type
      # Keywords that can't be used as names for fields
      RESERVED_KEYWORDS = Object.new.methods
      # Properties that aren't serialized
      UNSERIALIZABLE_PROPERTIES = ['@errors', '@value_errors']

      # The name of the field, used to adress it in templates. If you change
      # this in a field, you'll have to adjust your templates. This is however
      # NOT the authoritative identifier for your field.
      attr_accessor :name
      # A description of the field, this is purely to provide info to user of
      # the Store and can be displayed in you forms
      attr_accessor :description
      # The title for the field. For use in Forms, does not carry semantics
      attr_accessor :title
      # Indicate wether information for this field must be provided by users of
      # the store
      attr_accessor :required
      # The authoritative identifier for the field. You can change the title
      # however you want, the uid will always stay the same.
      attr_accessor :uid
      # Used to access errors that occured by validating the type instance
      # Access this right after calling valid?
      attr_reader   :errors
      
      # Automatically generates a uid and a name if none are provided in the
      # params Hash
      def initialize(params={})
        update_attributes(params)
        self.uid = generate_uid if self.uid.blank?
        self.name = self.title if self.name.blank? && !self.title.blank?
      end
      
      # Return a UUID
      #
      # Currently only works with MySQL databases. This will be fixed in future
      # versions
      def generate_uid
        # @TODO Only works with MySQL
        # rand to prevent mysql caching
        ActiveRecord::Base.connection.select_value(%Q(SELECT UUID() as "#{rand}"))
      end
      
      # Validate the type instance
      #
      # Performs basic validations for common properties of types and calls
      # the +validate+ method if you did provide one in your subclass.
      #
      # Your +validate+ method should push errors to the +@errors+ array. An
      # error should itself be an array of two fields, the first describing
      # the invalid property as a symbol, the second describing the error with
      # a String, similar to how ActiveRecord Errors work.
      #
      # After validation, you can access the errors through the type's
      # +errors+ attribute.
      def valid?
        @errors = []
        validate_base
        validate if self.respond_to?(:validate)
        @errors.empty?
      end
      
      # Set the title
      # If name is blank, a name is generated from the title and assigned
      def title=(t)
        @title = t
        self.name = t if name.blank?
      end
      
      # Set the name
      # The name is automatically converted to a friendly format that can be
      # accessed like a Ruby method later.
      def name=(n)
        @name = JsonObject::Helper.dehumanize(n)
      end
      
      # call-seq:
      #   required=(true)
      #   required=("true")
      #   required=(1)
      #   required=("1")
      #
      # Sets the required flag. Several "boolish" values are converted to
      # "true" automatically. All other evaluate to "false"
      def required=(r)
        @required = [true, "true", 1, "1"].include?(r)
      end
      
      def to_json(*args) # :nodoc:
        hash = {}
        self.instance_variables.each do |attr|
          next if UNSERIALIZABLE_PROPERTIES.include?(attr)
          hash[attr[1..-1]] = self.instance_variable_get(attr)
        end
        hash[:json_class] = self.class.name
        hash.to_json(*args)
      end
      
      def self.json_create(object) # :nodoc:
        type = self.allocate
        object.delete("json_class")
        type.update_attributes(object)
        type
      end
      
      # Return a copy of this type, but with a different uuid
      def copy
        new_type = JSON.parse(self.to_json)
        new_type.uid = generate_uid
        new_type
      end
      
      def update_attributes(hash)
        hash.each do |key, value|
          self.instance_variable_set("@#{key}", value)
        end
        self.required = @required
      end
      
      # Convert the content of the param to the values that gets stored in the JSON Store
      def value_from_param(param)
        param
      end
      
      # Convert the value stored in the JSON Store to a Ruby object
      def object_from_value(val)
        val
      end

      # call-seq:
      #   value_valid?(value)
      #
      # Validate a value of this type
      #
      # The store uses this to validate the values you assign to its fields
      # To validate a value, it looks up the corresponding type instance in
      # the Schema and passes the value to the type's value_valid? method.
      #
      # In the plain version, this simply checks wether the value is non-blank
      # in case the "required" option of the type was set to "true".
      #
      # By providing a +validate_value(value)+ method in your subclass you can
      # extend this behavior. Inside +validate_value+, push errors to the
      # +@value_errors+ instance variable. Each error should just be a simple
      # string describing what's wrong.
      def value_valid?(v)
        @value_errors = []
        validate_value_base(v)
        validate_value(v) if self.respond_to?(:validate_value)
        @value_errors.empty?
      end

      # Used to access errors that occured by validating the value stored in a field
      # with this type. Access this right after calling value_valid?
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