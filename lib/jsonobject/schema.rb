module JsonObject
  class UnknownSchemaAttributeError < NoMethodError # :nodoc:
  end
  
  class UnknownAssociationError < ActiveRecord::ActiveRecordError # :nodoc:
  end
  
  class Schema

    # The an array of fields (instances of the subclasses of JsonObject::Type)
    # the schema consists of
    attr_reader :fields
    # This can be used to access the errors that were found in calls to valid?
    # See #valid? for more information.
    attr_reader :errors

    def initialize(options = {})
      @options = Schema.default_options.merge(options)
      @fields = []
    end
    
    # Given a JSON string, parses it to create a Schema.
    #
    # If the string is blank a fresh Schema instance, initialized with
    # the provided options is returned
    def self.load_from_json_with_options(json, options = {}) # :nodoc:
      return Schema.new(options) if json.blank?
      
      schema = JSON.parse(json)
      if schema.is_a? Schema
        schema.instance_variable_set(:@options, Schema.default_options.merge(options))
      else
        schema = Schema.new(options)
      end
      schema
    end
    
    # Update the Schema with params data from a form.
    #  
    # The update method is what is called internally when accessing
    # category.schema = params[:category][:schema] (which is called
    # automatically) by ActiveRecord::Base when you write model.attributes =
    # params[:document]
    # 
    # Pass in an array of the following form
    # 
    #   [
    #    {'type' => 'JsonObject::Types::String',
    #     'uid'  => '<UID>',
    #     <... further options specific to the type>},
    #    <... further field hashes>]
    # 
    # Fields in the schema that are not included in the array are deleted from
    # the schema afterwards.
    def update(array)
      updated_uids = []
      for field_hash in array
        field_hash = field_hash.dup
        klass = field_hash.delete("type").constantize #TODO Security check, only constantize safe classes
        field_is_new = field_hash['uid'].blank?
        if field_is_new
          field = klass.new(field_hash)
          updated_uids << field.uid
          @fields << field
        else
          updated_uids << field_hash['uid']
          field = field_by_uid(field_hash.delete('uid'))
          field.update_attributes(field_hash)
        end
      end
      
      remove_fields_by_uids(updated_uids)
    end
    
    # Remove all fields with uids that are not in the submitted list
    # 
    # This is only a helper method used by update.
    def remove_fields_by_uids(uids) # :nodoc:
      @fields.reject! {|field| !uids.include?(field.uid)}
    end
    
    def to_json(*args) # :nodoc:
      { :json_class => "JsonObject::Schema",
        :fields     => @fields }.to_json(*args)
    end
    
    def self.json_create(object) # :nodoc:
      schema = self.allocate
      schema.instance_variable_set(:@fields, object['fields'])
      schema
    end
    
    # Return the field that matches +name+
    # 
    # <em>Aliased as []</em>
    def field_for(name)
      # TODO: We really only need one of both methods.
      field = @fields.find{|f| f.name == name}
      raise UnknownSchemaAttributeError.new("Attribute named '#{name}' not in store schema") if field.nil?
      field
    end
    
    # <em>Alias for field_for</em>
    def [](name)
      field_for(name)
    end
    
    # Check if the schema defines a field with the given name
    def has_field?(name)
      !!@fields.find{|f| f.name == name}
    end
    
    # Return the field that matches +uid+
    def field_by_uid(uid)
      field = @fields.find{|f| f.uid == uid}
      raise UnknownSchemaAttributeError.new("Attribute with UID '#{uid}' not in store schema") if field.nil?
      field 
    end
    
    # Perform a validation of the schema
    #
    # This verifies the schema and all of its fields.
    # - Checks for duplicate Names
    # - Checks for dupliate UIDs
    # - Calls the <em>JsonObject::Type#valid?</em> Method on every field
    # 
    # All errors can be accessed in the +errors+ attribute afterwards.
    # The format of errors is similar to that of ActiveRecord but not as sophisticated.
    # It is an array of pairs, the first element being the affected field's name
    # the second a description of the error. The description itself is either another
    # pair of the form <tt>[:field_attribute, "error description"]</tt> or a
    # list of such pairs.
    def valid?
      @errors = []
      names   = []
      uids    = []

      # validate fields
      fields.each do |field|
        @errors << [field.name, [:name, "is already in use"]] if names.include?(field.name)
        @errors << [field.name, [:uid,  "is already in use"]] if uids.include?(field.uid)
        names   << field.name
        uids    << field.uid
        @errors << [field.name, field.errors] unless field.valid?
      end
      
      @errors.empty?
    end
    
    # An Iterator over all fields in the schema
    def each_field(&block)
      # TODO Überflüssig
      @fields.each(block)
    end
    
    
    def self.default_options # :nodoc:
      @@default_options ||= { :allowed_types  => [
        'JsonObject::Types::Asset',
        'JsonObject::Types::Collection',
        'JsonObject::Types::String',
        'JsonObject::Types::Text',
        'JsonObject::Types::Date',
        'JsonObject::Types::Time',
        'JsonObject::Types::DateTime',
        'JsonObject::Types::Select',
        'JsonObject::Types::Multiselect'
      ]}
    end
    
    # Internal helper method
    def class_for_type(t) # :nodoc:
      t.constantize if @options[:allowed_types].include? t
    end
    
    # Return a copy of this schema, but with different uuids
    #
    # Use this on the console (or elsewhere) to duplicate Categories' schemas.
    def copy
      old_schema = self
      new_schema = Schema.new
      for field in old_schema.fields
        new_schema.fields << field.copy
      end
      new_schema
    end

  end # Schema
end # JsonObject