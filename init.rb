# Include hook code here

# Tell ActiveRecord::Base about JsonObject
require 'jsonobject'
ActiveRecord::Base.send :include, JsonObject

# Include VrameHelper
config.to_prepare do
  ApplicationController.helper(VrameHelper)
end

unless File.exist?(File.join(RAILS_ROOT, 'public', "vrame")) || ARGV[0] == "vrame:sync"
  raise "Please run rake vrame:sync before continuing" 
end