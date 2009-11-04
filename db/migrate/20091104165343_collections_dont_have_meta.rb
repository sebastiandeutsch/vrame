class CollectionsDontHaveMeta < ActiveRecord::Migration
  def self.up
    remove_column :collections, :meta_json
  end

  def self.down
    add_column :collections, :meta_json, :text
  end
end
