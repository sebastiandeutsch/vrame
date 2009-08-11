class Admin::LanguagesController < Admin::AdminController  
  def index
    per_page = params[:per_page] || 50
    
    @languages = Language.paginate :page => params[:page], :per_page => per_page
  end
  
  def edit
    @language = Language.find(params[:id])
  end
  
  def update
    @language = Language.find(params[:id])
    if @language.update_attributes params[:language]
      flash[:success] = 'Sprache aktualisiert'
      redirect_to :action => :index
    else
      flash[:error] = 'Es ist ein Fehler aufgetreten'
      render :action => :edit
    end    
  end  
  
  def create
    @language = Language.new(params[:language])
    if @language.save
      flash[:success] = 'Sprache angelegt'
      redirect_to :action => :index
    else
      flash[:error] = 'Es sind Fehler aufgetreten'
      redirect_to :action => :index
    end
 end
  
  def destroy
    @language = Language.find(params[:id])
    if @language.destroy
      flash[:success] = 'Die Sprache wurde gelöscht'
    else
      flash[:error] = 'Die Sprache konnte nicht gelöscht werden'  #TODO Error Messages hierhin
    end
    redirect_to :action => :index
  end  
end