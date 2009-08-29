module Paperclip
  class Attachment
    ImageFileExtensions = %W(jpg png gif)
    def self.is_image? (filename)
      logger.info "XXX File extension: #{File.extname(filename)[1..-1]}"
      ImageFileExtensions.include?(File.extname(filename)[1..-1])
    end
  end
end