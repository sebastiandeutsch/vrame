require 'paperclip_images'

class Asset < ActiveRecord::Base
  acts_as_list :scope => :assetable
  
  belongs_to :user
  belongs_to :assetable, :polymorphic => true
  
  has_attached_file :file,
    :path => ":rails_root/public/system/assets/:class/:id/:style.:extension",
    :url  =>                   "/system/assets/:class/:id/:style.:extension"
  
  has_attached_file :posterframe,
    :path => ":rails_root/public/system/assets/:class/:id/posterframe_:style.:extension",
    :url  =>                   "/system/assets/:class/:id/posterframe_:style.:extension",
    :styles => lambda { |attachment|
      # @TODO 
      # create configuration
      # which is controlable from env.rb
      # with mere hook
      {
        :menucarddesign_thumb => "85x57#",
        :qbus_large           => ["x506", :jpg],
        :qbus_medium          => ["294x166#", :jpg],
        :qbus_thumb           => ["x124", :jpg],
        :qbus_backend         => ["x57", :jpg],
        :vrame_backend      => "100x50",
        :thumbnail          => "100x140",
        :thumbnail_square   => "100x100#",
        :full               => "300x250",
        :bg_thumb           => "392x272"
      }
    }
    
  def serialize
    file.url
  end
  
  def self.create_from_file(file)
    # Basic attributes
    attributes = {
      :file => file,
      :user => @current_user
    }
    
    # Is the file an image?
    filename = file.respond_to?(:original_filename) ? file.original_filename : file.basename
    is_image = Paperclip::Attachment.is_image?(filename)
    
    # Create an Image instance or a generic Asset
    klass = is_image ? Image : Asset
    
    # Create asset record and return it
    klass.create(attributes)
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