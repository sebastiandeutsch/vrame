class VrameAddPosterframeToAssets < ActiveRecord::Migration
  def self.up
    add_column :assets, :posterframe_file_name, :string
    add_column :assets, :posterframe_content_type, :string
    add_column :assets, :posterframe_file_size, :string
    add_column :assets, :posterframe_updated_at, :datetime
  end

  def self.down
    remove_column :assets, :posterframe_file_name
    remove_column :assets, :posterframe_content_type
    remove_column :assets, :posterframe_file_size
    remove_column :assets, :posterframe_updated_at
  end
end
