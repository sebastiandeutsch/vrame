class Asset < ActiveRecord::Base  
  belongs_to :user
  
  has_attached_file :file,
    :url  => "/assets/:class/:id/:style.:extension",
    :path => ":rails_root/public/assets/:class/:id/:style.:extension"
end