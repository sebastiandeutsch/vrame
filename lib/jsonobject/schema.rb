module JsonObject
  class UnknownSchemaAttributeError < NoMethodError
  end
  
  class UnknownAssociationError < ActiveRecord::ActiveRecordError
  end
  
  class Schema
    include Serializable
    
    attr_reader :fields

    def initialize(options = {})
      set_options(options)
      @fields = []
    end
    
    def set_options(options = {})
      @options = Schema.default_options.merge(options)
    end
    
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
    
    def remove_fields_by_uids(uids)
      @fields.reject! {|field| !uids.include?(field.uid)}
    end
    
    def to_json(*args)
      { :json_class => "JsonObject::Schema",
        :fields     => @fields }.to_json(*args)
    end
    
    def self.json_create(object)
      schema = self.allocate
      schema.instance_variable_set(:@fields, object['fields'])
      schema
    end
    
    def field_for(name)
      field = @fields.find{|f| f.name == name}
      raise UnknownSchemaAttributeError.new("Attribute named '#{name}' not in store schema") if field.nil?
      field
    end
    
    def field_by_uid(uid)
      field = @fields.find{|f| f.uid == uid}
      raise UnknownSchemaAttributeError.new("Attribute with UID '#{uid}' not in store schema") if field.nil?
      field 
    end
    
    def has_attribute?(name)
      name = name.to_sym
      @fields.include?(name)
    end
    
    def each(&block)
      @fields.each(block)
    end
    
    def self.default_options
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
    
    def class_for_type(t)
      t.constantize if @options[:allowed_types].include? t
    end

  private
        
    def initialize_fields
      @fields = {}
      if @hash['fields'].is_a? Array
        @hash['fields'].each { |type| @fields[type.name] = type }
      end
    end
    
  end

end