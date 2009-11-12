require 'paperclip_filetypes'

class Asset < ActiveRecord::Base
  acts_as_list :scope => :assetable
  
  belongs_to :user
  belongs_to :assetable, :polymorphic => true
  
  attr_accessor :vrame_styles

  DEFAULT_STYLES = {
    :vrame_backend        => "100x50",
    :thumbnail            => "100x140",
    :thumbnail_square     => "100x100#",
    :full                 => "300x250",
    :bg_thumb             => "392x272"
  }
  
  has_attached_file :file,
    :path => ":rails_root/public/system/assets/:class/:id/:style.:extension",
    :url  =>                   "/system/assets/:class/:id/:style.:extension"
  
  has_attached_file :posterframe,
    :path => ":rails_root/public/system/assets/:class/:id/posterframe_:style.:extension",
    :url  =>                   "/system/assets/:class/:id/posterframe_:style.:extension",
    :styles => lambda { |attachment|
                  returning(HashWithIndifferentAccess.new) do |styles|
                    styles.merge!(attachment.instance.vrame_styles) if attachment.instance.vrame_styles.is_a? Hash
                    styles.merge!(Vrame.configuration.posterframe_styles)
                    styles.merge!(Asset::DEFAULT_STYLES)
                  end
                }

  after_post_process :store_posterframe_dimensions

  def store_posterframe_dimensions
    return unless self.posterframe?
    dim = Paperclip::Geometry.from_file(self.posterframe.queued_for_write[:original].path)
    self.posterframe_width  = dim.width
    self.posterframe_height = dim.height
  end
    
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
    @collection = Collection.find_or_create_by_id(collection_id) do |collection|
      collection.user = self.user      
      if parent_id && parent_type
        collection.collectionable_id   = parent_id
        collection.collectionable_type = parent_type
      end
    end

    @collection.assets << self

    @collection
  end
  
end