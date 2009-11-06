module Paperclip
  class Attachment
    ImageFileExtensions = %w(jpg png gif)
    MovieFileExtensions = %w(flv m4v)
    
    def self.is_image? (filename)
      ImageFileExtensions.include?(File.extname(filename)[1..-1])
    end
    
    def is_image? ()
      ImageFileExtensions.include?(File.extname(original_filename)[1..-1])
    end

    def self.is_movie? (filename)
      MovieFileExtensions.include?(File.extname(filename)[1..-1])
    end
    
    def is_movie? ()
      MovieFileExtensions.include?(File.extname(original_filename)[1..-1])
    end
    
  end
end