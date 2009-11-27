class AddBodyPlainTextColumnToNewsletters < ActiveRecord::Migration
  def self.up
    add_column :newsletters, :body_plain_text, :text
  end

  def self.down
    remove_column :newsletters, :body_plain_text
  end
end
