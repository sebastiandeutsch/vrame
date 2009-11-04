class Collection < ActiveRecord::Base
  
  belongs_to :collectionable, :polymorphic => true
  belongs_to :user
  
  has_many :assets, :order => "position", :dependent => :destroy, :as => :assetable
  
  has_json_store :meta
  
  def serialize
    assets.map(&:serialize)
  end
end