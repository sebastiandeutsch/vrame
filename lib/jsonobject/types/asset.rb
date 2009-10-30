module JsonObject
  module Types
    class Asset < JsonObject::Type
      attr_accessor :styles
      def object_from_value(val)
        ::Asset.find_by_id(val.to_i)
      end
    end
  end
end