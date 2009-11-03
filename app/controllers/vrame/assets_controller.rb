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
    #TODO Gucken ob vorhanden und eingaben absichern
    params[:vrame_styles] = JsonObject::Types::Asset.styles_for(params[:schema])
    params[:file] = params.delete(:Filedata) if params[:Filedata]
    params[:user] = @current_user
    
    @asset = Asset.factory(params)
    
    
    # Build response hash
    response = { :id => @asset.id }
    
    parent_type = params[:parent_type]
    parent_id   = params[:parent_id]
    
    # Set up assetable relation
    if params[:upload_type] == "collection"
      # The asset belongs to a collection
      @collection = @asset.initialize_collection(params[:collection_id], parent_type, parent_id)
      
      # Add collection id to the response
      response[:collection_id] = @collection.id
    else
      # The asset belongs directly to an object (e.g. Document)
      @asset.assetable_id   = parent_id
      @asset.assetable_type = parent_type
      @asset.save
    end
    
    # Render HTML for asset list item
    response[:asset_list_item] = render_to_string(:partial => 'vrame/shared/asset_list_item', :locals => { :asset => @asset })
    
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