# Include hook code here

# Tell ActiveRecord::Base about JsonObject
require 'jsonobject'
ActiveRecord::Base.send :include, JsonObject::Adapter

# Include VrameHelper
config.to_prepare do
  ApplicationController.helper(VrameHelper)
end