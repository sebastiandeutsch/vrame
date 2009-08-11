class Collection < ActiveRecord::Base
  has_many :images, :dependent => :destroy
  
  has_json_object :meta
end