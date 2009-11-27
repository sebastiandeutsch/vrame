class AddActiveColumnToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :active, :boolean, :default => false
  end

  def self.down
    remove_column :subscriptions, :active
  end
end
