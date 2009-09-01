class AddDocumentRefernceToAssets < ActiveRecord::Migration
  def self.up
    add_column :assets, :document_id, :integer
  end

  def self.down
    remove_column :assets, :document_id
  end
end
