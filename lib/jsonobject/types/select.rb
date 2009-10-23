module JsonObject
  module Types
    class Select < JsonObject::Type
      attr_accessor :options
      def options=(o)
        raise TypeError, "options for Select has to be an array of strings" unless o.is_a? Array
        o.map!{|e| e.to_s.strip}
        @options = o.reject {|e| e.blank?}
      end
      
      def validate
        if !@options.is_a?(Array) || @options.length < 2
          @errors << [:options, "müssen mindestens zwei Elemente enthalten"]
        end
      end
    end
  end
end