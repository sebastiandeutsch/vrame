class CategoryHideInNav < ActiveRecord::Migration
  def self.up
    add_column :categories, :hide_in_nav, :boolean
  end

  def self.down
    remove_column :categories, :hide_in_nav
  end
end
