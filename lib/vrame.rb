# Vrame - nothing to do here, yet
module Vrame
  
end

# Tell ActiveRecord::Base about JsonObject
require 'jsonobject'

ActiveRecord::Base.send :include, JsonObject