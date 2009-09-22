require 'paperclip_images'

class Asset < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :assetable, :polymorphic => true
  
  has_attached_file :file,
    :path => ":rails_root/public/system/assets/:class/:id/:style.:extension",
    :url  =>                   "/system/assets/:class/:id/:style.:extension"
  
  def serialize
    file.url
  end
end