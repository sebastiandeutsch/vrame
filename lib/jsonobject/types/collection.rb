module JsonObject
  module Types
    class Collection < JsonObject::Type
      attr_accessor :styles
      def object_from_value(val)
        ::Collection.find_by_id(val.to_i)
      end
    end
  end
end