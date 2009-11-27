class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.string :salutation
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :token

      t.timestamps
    end
  end

  def self.down
    drop_table :subscriptions
  end
end
