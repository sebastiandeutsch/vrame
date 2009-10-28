module JsonObject
  module Types
    class MultiSelect < Select
      def validate_value(values)
        @value_errors << "'#{values}' is not a subset of the list of valid options" unless values&options==values
      end
    end
  end
end