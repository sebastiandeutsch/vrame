class Vrame::AssetsController < Vrame::VrameController
  skip_before_filter :verify_authenticity_token, :only => :create
  skip_before_filter :require_user, :only => :create
  
  def create
    
    # TODO: or Image.create
    @asset = Asset.create(:user => @current_user, :file => params[:Filedata])
    
    @response = {
        :id  => @asset.id,
        :url => @asset.file.url(:thumbnail)
    }
    
    if params[:create_collection]
      # The asset is part of a collection
      
      # Find collection by collection_id or create new one
      @collection = Collection.find_or_create_by_id(params[:collection_id]) do |collection|
        collection.user_id = current_user.id
        collection.document_id = params[:document_id]
      end
    
      # Add asset to collection
      @collection.assets << @asset
    
      # Add collection id to the response
      @response[:collection_id] = @collection.id
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