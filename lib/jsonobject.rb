module JsonObject
  
  class Schema
    
    attr_reader :last_uid, :fields, :uid_map
    
    def initialize(schema = {})
      schema = HashWithIndifferentAccess.new(schema)
      
      @last_uid = schema.fetch(:last_uid, 0)
      
      @uid_map = {}
      
      @fields = schema.fetch(:fields, []).map do |field|
        uid = field.fetch(:uid) { @last_uid += 1 }
        uid_map[uid] = SchemaItem.new(field[:name], field[:type], uid)
      end
    end
    
    def each(&block)
      @fields.each(&block)
    end
    
    def to_hash
      { :last_uid => @last_uid,
        :fields   => @fields.map(&:to_hash) }
    end
    
  end
  
  class SchemaItem
    
    attr_accessor :name, :type, :uid
    
    def initialize(name, type, uid)
      @name = name
      @type = type
      @uid  = uid
    end
    
    def to_hash
      { :name => @name,
        :type => @type,
        :uid => @uid }
    end
    
  end
  
  class Store
    
    attr_reader :schema, :values, :param_map
    
    def initialize(store = {})
      store = HashWithIndifferentAccess.new(store)
      
      @schema = Schema.new(store.fetch(:schema, {}))
      
      @param_map = HashWithIndifferentAccess.new
      
      @values = []
      store.fetch(:values, {}).each_pair do |uid, value|
        schema_item = @schema.uid_map[uid]
        @values << store_item = StoreItem.new(schema_item, value)
        @param_map[Helper::dehumanize(schema_item.name)] = store_item
      end
    end
    
    def each(&block)
      @values.each(&block)
    end
    
    def method_missing(name)
      @param_map[name]
    end
    
    def to_hash
      { :schema => @schema.to_hash,
        :values => @values }
    end
    
  end
  
  class StoreItem
    
    attr_reader :schema_item, :value
    
    def initialize(schema_item, value)
      @schema_item = schema_item
      @value       = value
    end
    
    def name; @schema_item.name; end
    
    def type; @schema_item.type; end
    
    def uid; @schema_item.uid; end
    
    def to_s; @value; end
    
    def to_hash
      { :name  => @schema_item.name,
        :type  => @schema_item.type,
        :uid   => @schema_item.uid,
        :value => @value }
    end
    
  end
  
  module Helper
    def self.dehumanize(human_string)
      # @TODO: - if first char is a number, append an underscore
      #        - collisions might occur
      #        - replace invalid characters
      human_string.downcase.gsub(/ +/,'_')
    end
  end
  
  module Adapter
    def self.included(mod)
      mod.extend(ClassMethods)
    end
    
    module SingletonMethods
    end

    module InstanceMethods
    end

    module ClassMethods
      
      def has_json_schema(name, options = {})
        extend JsonObject::Adapter::SingletonMethods
        include JsonObject::Adapter::InstanceMethods
        
        JsonObject::Adapter::InstanceMethods.send "define_method", "#{name}" do |*args|
          Schema.new(ActiveSupport::JSON.decode(self.send("#{name}_json")))
        end

        JsonObject::Adapter::InstanceMethods.send "define_method", "#{name}=" do |object|
          self.send "#{name}_json=", object.to_hash.to_json
        end
        
      end
      
      def has_json_store(name, options = {})
        extend JsonObject::Adapter::SingletonMethods
        include JsonObject::Adapter::InstanceMethods
    
        write_inheritable_attribute(:json_store_definitions, {}) if json_store_definitions.nil?
        json_store_definitions[name] = options

        JsonObject::Adapter::InstanceMethods.send "define_method", "#{name}" do |*args|
          if self.send("#{name}_json")
            object = ActiveSupport::JSON.decode(self.send("#{name}_json"))
          else
            object = {}
          end
          
          if schema = self.class.json_store_definitions[name][:schema]
            object[:schema] = [self, schema].flatten.inject { |current, parent| current.send(parent) }.to_hash
          end
          
          object = Store.new(object)
        end

        JsonObject::Adapter::InstanceMethods.send "define_method", "#{name}=" do |object|
          self.send "#{name}_json=", object.to_hash.to_json
        end
      end

      def json_store_definitions
        read_inheritable_attribute(:json_store_definitions)
      end
    end
    
  end

end