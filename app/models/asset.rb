require 'paperclip_images'

class Asset < ActiveRecord::Base
  acts_as_list :scope => :assetable
  
  belongs_to :user
  belongs_to :assetable, :polymorphic => true
  
  attr_accessor :vrame_styles
  
  has_attached_file :file,
    :path => ":rails_root/public/system/assets/:class/:id/:style.:extension",
    :url  =>                   "/system/assets/:class/:id/:style.:extension"
  
  def serialize
    file.url
  end
  
  def self.factory(attributes)
    file = attributes[:file]
    filename = file.respond_to?(:original_filename) ? file.original_filename : file.basename
    is_image = Paperclip::Attachment.is_image?(filename)
    klass = is_image ? Image : Asset
    klass.create(:file => file, :user => attributes[:user], :vrame_styles => attributes[:vrame_styles])
  end
  
  def initialize_collection(collection_id = nil, parent_type = nil, parent_id = nil)
    # Find collection by collection_id or create new one
    @collection = Collection.find_or_create_by_id(collection_id) do |collection|
      # New collection
      
      # Set up user relation
      collection.user_id = @current_user.id
      
      # Set up collection owner
      if parent_id and parent_type
        collection.collectionable_id   = parent_id
        collection.collectionable_type = parent_type
      end
    end

    # Add asset to collection
    @collection.assets << self
    
    # Return the collection
    @collection
  end
  
end