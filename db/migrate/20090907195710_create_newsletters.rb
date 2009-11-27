class CreateNewsletters < ActiveRecord::Migration
  def self.up
    create_table :newsletters do |t|
      t.string   :title
      t.text     :body
      t.datetime :publish_on
      t.boolean  :dispatched, :default => false
      t.integer  :recipients

      t.timestamps
    end
  end

  def self.down
    drop_table :newsletters 
  end
end