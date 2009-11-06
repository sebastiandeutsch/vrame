# Vrame - nothing to do here, yet
module Vrame
  class << self
    # The Configuration instance used to configure the NineAuthEngine
    def configuration
      @@configuration ||= Configuration.new
    end

    def configuration=(configuration)
      @@configuration = configuration
    end

    def configure
      yield Vrame.configuration if block_given?
    end
  end
  
  class Configuration
    attr_accessor :image_styles, :posterframe_styles
                  
    def initialize()  
      self.image_styles       = HashWithIndifferentAccess.new
      self.posterframe_styles = HashWithIndifferentAccess.new
    end
  end
  
end