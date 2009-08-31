require 'paperclip_images'

class Asset < ActiveRecord::Base  
  belongs_to :user
  
  has_attached_file :file,
    :url  => "/system/assets/:class/:id/:style.:extension",
    :path => ":rails_root/public/system/assets/:class/:id/:style.:extension"
end