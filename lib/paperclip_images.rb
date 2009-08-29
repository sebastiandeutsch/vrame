module Paperclip
  class Attachment
    ImageFileExtensions = %W(jpg png gif)
    def self.is_image? (filename)
      ImageFileExtensions.include?(File.extname(filename)[1..-1])
    end
  end
end