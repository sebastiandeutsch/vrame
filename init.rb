# Load JsonObject
require 'json/add/core'
require File.join(File.dirname(__FILE__), "lib", "jsonobject")

# Include VrameHelper
config.to_prepare do
  ApplicationController.helper(VrameHelper)
end

unless File.exist?(File.join(RAILS_ROOT, 'public', "vrame")) || ARGV[0] == "vrame:sync"
  raise "Please run rake vrame:sync before continuing" 
end