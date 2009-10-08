# Include hook code here

# Tell ActiveRecord::Base about JsonObject
require 'jsonobject'
ActiveRecord::Base.send :include, JsonObject

config.gem 'coupa-acts_as_list',
  :lib => 'coupa-acts_as_list',
  :source => 'http://gems.github.com'

config.gem 'coupa-acts_as_tree',
  :lib => 'coupa-acts_as_tree',
  :source => 'http://gems.github.com'

config.gem 'binarylogic-authlogic',
  :lib     => 'authlogic',
  :source  => 'http://gems.github.com'

config.gem 'mislav-will_paginate',
  :lib => 'will_paginate',
  :source => 'http://gems.github.com'

config.gem 'mini_magick',
  :lib => 'mini_magick'

config.gem 'thoughtbot-paperclip',
  :lib => 'paperclip',
  :source => 'http://gems.github.com'

config.gem 'norman-friendly_id',
  :lib => 'friendly_id',
  :source => 'http://gems.github.com'
    
config.gem 'daemons'

# Include VrameHelper
config.to_prepare do
  ApplicationController.helper(VrameHelper)
end

unless File.exist?(File.join(RAILS_ROOT, 'public', "vrame")) || ARGV[0] == "vrame:sync"
  raise "Please run rake vrame:sync before continuing" 
end