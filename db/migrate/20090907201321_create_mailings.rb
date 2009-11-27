class CreateMailings < ActiveRecord::Migration
  def self.up
    create_table :mailings do |t|
      t.references :subscription
      t.references :newsletter      
      t.boolean    :delivered, :default => false
    end
  end

  def self.down
    drop_table :mailings
  end
end
