class NewJsonobjectToFlexitypes < ActiveRecord::Migration
  def self.up
    Category.all.each do |category|
      json = JSON.parse(category.schema_json, :create_additions => false)
      next if json.has_key?('json_class')
      json['json_class'] = "JsonObject::Schema"
      json['fields'].each do |field|
        field['json_class'] = case field['type']
        when /String/i
          "JsonObject::Types::String"
        when /Text/i
          "JsonObject::Types::Text"
        when /Datetime/i
          "JsonObject::Types::Datetime"
        when /Bool|Boolean/i
          "JsonObject::Types::Bool"
        when /File|Asset/i
          "JsonObject::Types::Asset"
        when /Collection/i
          "JsonObject::Types::Collection"
        when /Placemark/i
          "JsonObject::Types::Placemark"
        when /Select/i
          "JsonObject::Types::Select"
        when /Multiselect/i
          "JsonObject::Types::Multiselect"
        end
        field.delete 'type'
      end
      category.schema_json = json.to_json
      category.save
    end
    
    Document.all.each do |document|
      json = JSON.parse(document.meta_json, :create_additions => false)
      next if json.has_key?('json_class')
      json['json_class'] = "JsonObject::Store"
      document.meta_json = json.to_json
      document.save
    end
  end

  def self.down
  end
end
