class PolymorphicCollections < ActiveRecord::Migration
  def self.up
    add_column :collections, :collectionable_id, :integer
    add_column :collections, :collectionable_type, :string
    
    Collection.all.each do |c|
      p "Collection##{c.id} belongs_to Document##{c.document_id}"
      c.collectionable_type = "Document"
      c.collectionable_id = c.document_id
      c.save
    end
    
    remove_column :collections, :document_id
  end

  def self.down
    remove_column :collections, :collectionable_id
    remove_column :collections, :collectionable_type
    add_column :collections, :document_id, :integer
  end
end
