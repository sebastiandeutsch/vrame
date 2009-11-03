module JsonObject
  module Types
    class Asset < JsonObject::Type
      attr_accessor :styles
      def object_from_value(val)
        ::Asset.find_by_id(val.to_i)
      end
      
      def self.styles_for(schema_params)
        klass     = schema_params[:class].constantize # @TODO Security check
        id        = schema_params[:id]
        attribute = schema_params[:attribute]
        uid       = schema_params[:uid]
        # @TODO Catch errors
        
        schema = klass.find(id).send(attribute)
        raise "Schema #{attrib} not found in #{klass.name} #{id}" unless schema
        field  = schema.field_by_uid(uid)
        raise "Field #{uid} not found in #{klass.name} #{id}, schema #{attrib}" unless field
        styles = {}
        (field.styles || {}).each do |s|
          styles[s['key']] = s['style']
        end
        styles
      end
      
    end
  end
end