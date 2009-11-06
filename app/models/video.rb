class Video < Asset
  belongs_to :collection
  
  has_attached_file :file,
    :path => ":rails_root/public/system/assets/:class/:id/:filename",
    :url  =>                   "/system/assets/:class/:id/:filename"

  has_attached_file :posterframe,
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
