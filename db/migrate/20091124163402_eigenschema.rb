class Eigenschema < ActiveRecord::Migration
  def self.up
    add_column :categories, :eigenschema_json, :text
  end

  def self.down
    remove_column :categories, :eigenschema_json
  end
end
