module JsonObject
  module Types
    class Video < JsonObject::Types::Asset
      attr_accessor :styles
      def object_from_value(val)
        ::Video.find_by_id(val.to_i)
      end
            
    end
  end
end