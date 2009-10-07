# Load JsonObject
require 'json/add/core'
require File.join(File.dirname(__FILE__), "lib", "jsonobject")

# Include VrameHelper
config.to_prepare do
  ApplicationController.helper(VrameHelper)
end