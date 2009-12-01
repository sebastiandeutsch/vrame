class GetDimensionsFromExistingFiles < ActiveRecord::Migration
  def self.up
    Asset.all.each do |asset|
      puts "Asset #{asset}"
      if asset.posterframe?
        dim = Paperclip::Geometry.from_file(asset.posterframe.path(:original))
        asset.posterframe_width  = dim.width
        asset.posterframe_height = dim.height
        puts "  Posterframe: #{dim}"
      end
      if asset.file? && asset.file.is_image?
        filepath = asset.file.path(:original)
        if File.exist?(filepath)
          dim = Paperclip::Geometry.from_file(filepath)
          asset.file_width  = dim.width
          asset.file_height = dim.height
          puts "  File: #{dim}"
        end
      end
      asset.save
    end
  end

  def self.down
  end
end
