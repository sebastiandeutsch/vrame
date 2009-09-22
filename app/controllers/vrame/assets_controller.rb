require 'paperclip_images'

class Vrame::AssetsController < Vrame::VrameController
  skip_before_filter :verify_authenticity_token, :only => :create
  skip_before_filter :require_user, :only => :create
  
  def create
    
    # Get the file
    @file = params[:Filedata]
    
    # Basic attributes
    attributes =  { :file => @file, :user => @current_user }
    
    # Set up document association if document id given
    attributes[:document_id] = params[:document_id].to_i if params[:document_id]
    
    # Is the file an image?
    is_image = Paperclip::Attachment.is_image?(@file.original_filename)
    
    # Create an Image instance or a generic Asset
    klass = is_image ? Image : Asset
    
    # Create record
    @asset = klass.create(attributes)
    
    # Build response
    @response = {
        :id       => @asset.id,
        :url      => @asset.file.url,
        :filename => @asset.file.original_filename
    }
    
    if is_image
      @response[:is_image]  = true
      @response[:thumbnail] = @asset.file.url(:thumbnail)
    end
    
    if params[:parent_type] == "collection"
      # The asset is part of a collection
      
      # Find collection by collection_id or create new one
      @collection = Collection.find_or_create_by_id(params[:collection_id]) do |collection|
        # New collection: Set user id and document id
        collection.user_id = current_user.id
        collection.document_id = params[:document_id]
      end
    
      # Add asset to collection
      @collection.assets << @asset
    
      # Add collection id to the response
      @response.merge! :collection_id => @collection.id
    end
    
    # Render response
    render :json => @response
  end
  
  def destroy
    Asset.destroy(params[:id])
    if request.xhr?
      render :text => 'OK'
    else
      redirect_to :back
    end
  end
  
  def edit 
    @asset = Asset.find(params[:id])
  end
  
  def update
    @asset = Asset.find(params[:id])
    params[:asset][:user_id] = @current_user.id
    if @asset.update_attributes(params[:asset])
      flash[:success] = 'Datei aktualisiert'
      redirect :back
    else
      flash[:error] = 'Es ist ein Fehler aufgetreten'
      render :action => :edit
    end
  end
  
  def index
    render :text => 'yay'
  end
  
  private
    def single_access_allowed?
      action_name == 'create'
    end
end