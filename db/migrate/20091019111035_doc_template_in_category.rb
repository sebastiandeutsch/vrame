class DocTemplateInCategory < ActiveRecord::Migration
  def self.up
    add_column :categories, :document_template, :string
    add_column :categories, :document_layout, :string
  end

  def self.down
    remove_column :categories, :document_layout
    remove_column :categories, :document_template
  end
end
