class Vrame::AssetsController < Vrame::VrameController
  skip_before_filter :verify_authenticity_token, :only => :create
  skip_before_filter :require_user, :only => :create
  
  def create
    # Find collection by collection_id or create new one
    @collection = Collection.find_or_create_by_id(params[:collection_id]) do |collection|
      collection.user_id = current_user.id
      collection.title = 'Kein Titel'
    end
    
    # Add image to collection
    @image = @collection.images.create(:user => @current_user, :file => params[:Filedata])
    
    render :json => {
        :collection_id => @collection.id,
        :id  => @image.id,
        :url => @image.file.url(:thumbnail)
    }
  end
  
  def destroy
    Image.destroy(params[:id])
    redirect_to :back
  end
  
  def edit 
    @image = Image.find(params[:id])
  end
  
  def update
    @image = Image.find(params[:id])
    params[:image][:user_id] = @current_user.id
    if @image.update_attributes(params[:image])
      flash[:success] = 'Bild aktualisiert'
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
    def single_access_allowed?; action_name == 'create'; end
end