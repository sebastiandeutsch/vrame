class ChangeIso3ToIso2InLanguages < ActiveRecord::Migration
  def self.up
    rename_column :languages, :iso3_code, :iso2_code
  end

  def self.down
    rename_column :albums, :iso2_code, :iso3_code
  end
end
