class Image < Asset
  belongs_to :collection
  
  DEFAULT_STYLES = {
    :vrame_backend        => "100x50",
    :thumbnail            => "100x140",
    :thumbnail_square     => "100x100#",
    :full                 => "300x250",
    :bg_thumb             => "392x272"
  }
  
  has_attached_file :file,
    :path => ":rails_root/public/system/assets/:class/:id/:style.:extension",
    :url  =>                   "/system/assets/:class/:id/:style.:extension",
    :styles => lambda { |attachment|
                  if attachment.instance.vrame_styles.is_a? Hash
                    Image::DEFAULT_STYLES.merge(attachment.instance.vrame_styles)
                  else
                    Image::DEFAULT_STYLES
                  end
                },
    :convert_options => { :all => "-quality 80 -colorspace RGB -strip" }
    
end