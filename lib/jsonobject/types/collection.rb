module JsonObject
  module Types
    class Collection < JsonObject::Type
      attr_accessor :styles

      def styles=(s)
        raise TypeError, "styles for Collection has to be an array" unless s.is_a? Array
        s.each do |e|
          e['key']   = e['key'].to_s.strip
          e['style'] = e['style'].to_s.strip
        end
        @styles = s.reject {|e| e['style'].blank? || e['key'].blank? }
      end

      def object_from_value(val)
        ::Collection.find_by_id(val.to_i)
      end
    end
  end
end