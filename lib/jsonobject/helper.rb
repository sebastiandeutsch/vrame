module JsonObject
  module Helper
    def self.dehumanize(human_string)
      # @TODO: - if first char is a number, append an underscore
      #        - collisions might occur
      #        - replace invalid characters
      human_string.downcase.gsub(/ +/,'_')
    end
  end
end