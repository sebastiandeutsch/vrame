class Collection < ActiveRecord::Base
  
  belongs_to :collectionable, :polymorphic => true
  belongs_to :user
  
  has_many :assets, :order => "position", :dependent => :destroy, :as => :assetable
  
  def serialize
    assets.map(&:serialize)
  end
end