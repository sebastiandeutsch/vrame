class NewJsonObject < ActiveRecord::Migration
  def self.up
    # Migrate schemas
    Category.all.each do |category|
      old_json_string = category.schema_json
      
      old_schema_hash = json_decode(old_json_string) || []
      
      new_schema_hash = {
        'fields' => []
      }
      
      old_schema_hash.each do |field|
        new_schema_hash['fields'] << {
          'uid'   => field['uid'],
          'type'  => field['type'],
          'title' => field['name']
        }
      end
      
      category.schema_json = "{}"
      category.schema = new_schema_hash
      
      category.save
      
      # Just fancy output from here on
      num_fields = new_schema_hash['fields'].length
      
      puts "Converted #{num_fields} field(s) for category: #{category.to_param}"
    end
    
    # Migrate stores
    Document.all.each do |document|
      old_json_string = document.meta_json
      
      old_store_hash = json_decode(old_json_string) || {}
      
      new_store_hash = {
        'values' => old_store_hash
      }
      
      document.update_attribute(:meta_json, new_store_hash.to_json)
      
      # Just fancy output from here on
      puts "Converted document: #{document.to_param}"
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end

def json_decode(json_string)
  case json_string
    when "null"
      nil
    else
      ActiveSupport::JSON.decode(json_string)
  end
end