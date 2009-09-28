class AddLayoutToCategoriesAndDocuments < ActiveRecord::Migration
  def self.up
    add_column :categories, :layout,       :string
    add_column :documents,  :layout,       :string
  end

  def self.down
    remove_column :categories, :layout
    remove_column :documents,  :layout    
  end
end
