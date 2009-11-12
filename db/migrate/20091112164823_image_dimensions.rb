class ImageDimensions < ActiveRecord::Migration
  def self.up
    add_column :assets, :file_width, :integer
    add_column :assets, :file_height, :integer
    add_column :assets, :posterframe_width, :integer
    add_column :assets, :posterframe_height, :integer
  end

  def self.down
    remove_column :assets, :posterframe_height
    remove_column :assets, :posterframe_width
    remove_column :assets, :file_height
    remove_column :assets, :file_width
  end
end
