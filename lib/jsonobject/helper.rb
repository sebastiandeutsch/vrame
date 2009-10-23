module JsonObject
  module Helper
    UMLAUTS = {"ä" => "ae",
               "ö" => "oe",
               "ü" => "ue",
               "ß" => "ss"}
    
    def self.dehumanize(human_string)
      # @TODO: - if first char is a number, append an underscore
      #        - collisions might occur
      #        - replace invalid characters
      out = human_string.mb_chars
      out.downcase!
      out.strip!
      out.gsub!(/[\!\@\#\$\%\^\&\*\(\)\=\+\. -]+/,'_')
      UMLAUTS.each do |umlaut, subst|
        out.gsub!(umlaut, subst)
      end
      out.to_s
    end
  end
end