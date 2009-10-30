module JsonObject
  module Types
    class Bool < JsonObject::Type
      def value_from_param(boolish)
        [true, "true", 1, "1"].include?(boolish)
      end
      
      def object_from_value(val)
        [true, "true", 1, "1"].include?(val)
      end
    end
  end
end