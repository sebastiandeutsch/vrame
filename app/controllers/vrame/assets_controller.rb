require 'paperclip_images'

class Vrame::AssetsController < Vrame::VrameController
  
  skip_before_filter :verify_authenticity_token, :only => :create
  skip_before_filter :require_user, :only => :create
  
  def index
    per_page = params[:per_page] || 50
    @assets = Asset.paginate :page => params[:page], :per_page => per_page
  end
  
  def show
    @asset = Asset.find(params[:id])
    if @asset.assetable
      redirect_to [:edit, :vrame, @asset.assetable]
    else
      flash[:error] = 'Zugehörigkeit des Assets nicht gefunden'
      redirect_to :back
    end
  end
  
  # no new action
  
  def create
    
    # Get the file
    @file = params[:Filedata]
    
    # Basic attributes
    attributes =  { :file => @file, :user => @current_user }
    
    # Set up association if parent id given
    if params[:parent_id] and params[:parent_type]
      attributes[:assetable_id]   = params[:assetable_id]
      attributes[:assetable_type] = params[:assetable_type]
    end
    
    # Is the file an image?
    is_image = Paperclip::Attachment.is_image?(@file.original_filename)
    
    # Create an Image instance or a generic Asset
    klass = is_image ? Image : Asset
    
    # Create asset record
    @asset = klass.create(attributes)
    
    # Build response
    response = {
        :id => @asset.id
    }
    
    # Handle collection membership
    if params[:upload_type] == "collection"
      # The asset is part of a collection
      
      # Find collection by collection_id or create new one
      @collection = Collection.find_or_create_by_id(params[:collection_id]) do |collection|
        # New collection
        
        # Set up user relation
        collection.user_id = current_user.id
        
        # Set up collection owner
        collection.collectionable_id   = params[:parent_id]
        collection.collectionable_type = params[:parent_type]
      end
    
      # Add asset to collection
      @collection.assets << @asset
    
      # Add collection id to the response
      response[:collection_id] = @collection.id
    end
    
    # Render HTML for asset list item
    response[:asset_list_item] = render_to_string :partial => 'vrame/shared/asset_list_item', :locals => { :asset => @asset }
    
    # Send JSON response
    render :json => response
  end
  
  def edit 
    @asset = Asset.find(params[:id])
  end
  
  def update
    @asset = Asset.find(params[:id])
    params[:asset][:user_id] = @current_user.id
    
    if @asset.update_attributes(params[:asset])
      if request.xhr?
        render :text => 'OK'
      else
        flash[:success] = 'Asset aktualisiert'
        redirect_to :back
      end
    else 
      if request.xhr?
        render :text => 'Error'
      else
        flash[:error] = 'Fehler beim Löschen des Assets'
        redirect_to :back
      end
    end
  end
  
  def destroy
    @asset = Asset.find(params[:id])
    
    if @asset and @asset.destroy
      if request.xhr?
        render :text => 'OK'
      else
        flash[:success] = 'Asset gelöscht'
        redirect_to :back
      end
    else 
      if request.xhr?
        render :text => 'Error'
      else
        flash[:error] = 'Fehler beim Löschen des Assets'
        redirect_to :back
      end
    end
  end
  
  private
    def single_access_allowed?
      action_name == 'create'
    end
end