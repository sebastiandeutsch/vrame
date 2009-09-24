class AddCounterCachesToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :categories_count, :integer, :default => 0
    add_column :categories, :documents_count,  :integer, :default => 0
    
    Category.reset_column_information
    Category.all.each do |c|
      Category.update_counters c.id, :categories_count => c.children.length
      Category.update_counters c.id, :documents_count   => c.documents.length
    end
  end

  def self.down
    remove_column :categories, :categories_count
    remove_column :categories, :children_count
  end
end
