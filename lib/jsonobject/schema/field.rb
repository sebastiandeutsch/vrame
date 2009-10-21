module JsonObject
  class Schema
    class Field < OpenStruct
      
      def initialize(hash, schema)
        @schema = schema
        
        super(hash)
        
        assign_uid_if_empty
        assign_name_if_empty
      end
      
      def type
        @table[:type]
      end
      
      def get_value_from_store(store)
        value = store.values[uid]
        typed_value(value)
      end
      
      def set_value_in_store(value, store)
        if mapped_class_for_type
          if type_descends_from_active_record_base?
            value = value.id
          else
            value.update('json_class', type)
          end
        end
        
        store.values[uid] = value
      end
      
    private
    
      def assign_uid_if_empty
        uid ||= generate_next_uid
      end
      
      def generate_next_uid
        # @TODO Only works with MySQL
        ActiveRecord::Base.connection.select_value("SELECT UUID();")
      end
      
      def assign_name_if_empty
        name ||= generate_name_from_title
      end
      
      def generate_name_from_title
        Helper.dehumanize(title) if not title.nil?
      end
      
      def typed_value(value)
        if type_descends_from_active_record_base?
          active_record_for(value)
        else
          value
        end
      end
      
      def type_descends_from_active_record_base?
        mapped_class_for_type.ancestors.include?(ActiveRecord::Base)
      end
      
      def active_record_for(value)
        mapped_class_for_type.find_by_id(value.to_i)
      end
      
      def mapped_class_for_type
        @mapped_class_for_type ||= @schema.mappings[type]
      end
      
    end
  end
end