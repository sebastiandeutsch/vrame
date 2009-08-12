# JsonSchema
# class JsonSchema
#   attr_accessor :name, :type, :uid
#   
#   
# end

# JsonObject
module JsonObject
  class JsonItem < HashWithIndifferentAccess # Hash
    def try(name)
      if self[name]
        self[name]
      else
        ""
      end
    end
    
    def type
      if self[:type]
        self[:type]
      else
        ""
      end
    end
    
    def method_missing(method_name, *args) 
      self[method_name.to_sym]
    end
  end
  
  def self.included(mod)
    mod.extend(ClassMethods)
  end 
  
  module SingletonMethods
  end
  
  module InstanceMethods
  end
  
  module ClassMethods
    def has_json_object(name_as_sym, options = {})
      extend JsonObject::SingletonMethods
      include JsonObject::InstanceMethods
      
      write_inheritable_attribute(:json_object_definitions, {}) if json_object_definitions.nil?
      json_object_definitions[name_as_sym] = options
      
      JsonObject::InstanceMethods.send "define_method", "#{name_as_sym.to_s}" do |*args|
        if self.send("#{name_as_sym.to_s}_json")
          object = ActiveSupport::JSON.decode(self.send("#{name_as_sym.to_s}_json"))
          
          # after_read callback
          after_read = self.class.json_object_definitions[name_as_sym][:after_read]
          object = after_read.call(self, object) unless after_read.nil?
          
          object
        else
          self.class.json_object_definitions[name_as_sym][:default]
        end
      end
      
      JsonObject::InstanceMethods.send "define_method", "#{name_as_sym.to_s}=" do |*args|
        object = args[0]
        
        # before_serialize callback
        before_serialize = self.class.json_object_definitions[name_as_sym][:before_serialize]
        object = before_serialize.call(object) unless before_serialize.nil?
        
        self.send "#{name_as_sym.to_s}_json=", object.to_json
      end
    end
    
    def json_object_definitions
      read_inheritable_attribute(:json_object_definitions)
    end
  end
end

