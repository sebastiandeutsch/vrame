class Collection < ActiveRecord::Base
  belongs_to :document
  
  has_many :assets, :dependent => :destroy
  
  has_json_object :meta
end