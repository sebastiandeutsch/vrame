class ChangeIso3ToIso2InLanguages < ActiveRecord::Migration
  MAP = {'deu' => 'de', 'eng' => 'en'}
  def self.up
    rename_column :languages, :iso3_code, :iso2_code
    Language.reset_column_information
    Language.find_each {|l| l.update_attribute(:iso2_code, MAP[l.iso2_code]) }
  end

  def self.down
    rename_column :albums, :iso2_code, :iso3_code
    Language.reset_column_information
    Language.find_each {|l| l.update_attribute(:iso2_code, MAP.invert[l.iso2_code]) }
  end
end
