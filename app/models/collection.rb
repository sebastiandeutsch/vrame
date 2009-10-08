class Collection < ActiveRecord::Base
  
  belongs_to :collectionable, :polymorphic => true
  
  has_many :assets, :order => "position", :dependent => :destroy, :as => :assetable
  
  has_json_object :meta
  
  def serialize
    assets.map(&:serialize)
  end
end