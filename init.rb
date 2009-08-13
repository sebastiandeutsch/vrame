# Include hook code here

# Tell ActiveRecord::Base about JsonObject
require 'jsonobject'
ActiveRecord::Base.send :include, JsonObject
