require 'paperclip_images'

class Vrame::AssetsController < Vrame::VrameController
  skip_before_filter :verify_authenticity_token, :only => :create
  skip_before_filter :require_user, :only => :create
  
  def create
    
    @file = params[:Filedata]
    # Is the file an image?
    if Paperclip::Attachment.is_image?(@file.original_filename)
    attributes =  { :user => @current_user, :file => @file }
      @asset = Image.create attributes
      @response = {
        :id  => @asset.id,
        :url => @asset.file.url(:thumbnail),
        :is_image => true
      }
    else
      @asset = Asset.create attributes
      @response = {
        :id  => @asset.id,
        :url => @asset.file.original_filename
      }
    end
    
    if params[:create_collection]
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
    
    render :json => @response
  end
  
  def destroy
    Asset.destroy(params[:id])
    redirect_to :back
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