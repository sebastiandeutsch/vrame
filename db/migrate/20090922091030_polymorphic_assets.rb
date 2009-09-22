class PolymorphicAssets < ActiveRecord::Migration
  def self.up
    add_column :assets, :assetable_id, :integer
    add_column :assets, :assetable_type, :string
    
    Asset.all.each do |a|
      if a.document_id
        p "Asset##{a.id} belongs_to Document##{a.document_id}"
        a.assetable_type = "Document"
        a.assetable_id = a.document_id
      elsif a.collection_id
        p "Asset##{a.id} belongs_to Collection##{a.collection_id}"
        a.assetable_type = "Collection"
        a.assetable_id = a.collection_id
      end
      a.save
    end
    
    remove_column :assets, :collection_id
    remove_column :assets, :document_id
  end

  def self.down
    remove_column :assets, :assetable_id
    remove_column :assets, :assetable_type
    add_column :assets, :collection_id, :integer
    add_column :assets, :document_id, :integer
  end
end
