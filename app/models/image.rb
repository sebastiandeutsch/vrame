class Image < Asset
  belongs_to :collection
  
  has_attached_file :file,
    :path => ":rails_root/public/system/assets/:class/:id/:style.:extension",
    :url  =>                   "/system/assets/:class/:id/:style.:extension",
    :styles => lambda { |attachment|
                  returning(HashWithIndifferentAccess.new) do |styles|
                    styles.merge!(attachment.instance.vrame_styles) if attachment.instance.vrame_styles.is_a? Hash
                    styles.merge!(Vrame.configuration.image_styles) if Vrame.configuration.image_styles.is_a? Hash
                    styles.merge!(Asset::DEFAULT_STYLES)
                  end
                },
    :convert_options => { :all => "-quality 80 -colorspace RGB -strip" }
    
    after_post_process :store_dimensions
    
    def store_dimensions
      return unless self.file?
      dim = Paperclip::Geometry.from_file(self.file.queued_for_write[:original].path)
      self.file_width  = dim.width
      self.file_height = dim.height
    end
    
end