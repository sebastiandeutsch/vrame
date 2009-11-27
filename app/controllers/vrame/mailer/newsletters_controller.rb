class Vrame::Mailer::NewslettersController < Vrame::VrameController
  def index
    per_page = params[:per_page] || 50
    
    @newsletters = Newsletter.paginate :page => params[:page], :per_page => per_page, :order => :created_at
  end
  
  def destroy
    @newsletter = Newsletter.find(params[:id])
    if @newsletter.destroy
      flash[:success] = 'Newsletter wurde gelöscht'
    else
      flash[:error] = 'Newsletter konnte nicht gelöscht werden'
    end
    redirect_to :action => :index
  end
  
  def new
    @newsletter = Newsletter.new
  end
  
   def create
     @newsletter = Newsletter.new(params[:newsletter])

     if @newsletter.save
       flash[:success] = 'Newsletter angelegt'
       redirect_to :action => :index
     else
       flash[:error] = 'Newsletter konnte nicht angelegt werden'
       render :new
     end
  end
  
  def edit
    @newsletter = Newsletter.find(params[:id])
  end
  
  def update
    @newsletter = Newsletter.find(params[:id])
    
    if @newsletter.update_attributes(params[:newsletter])
      flash[:success] = 'Newsletter aktualisiert'
      redirect_to vrame_mailer_newsletters_path
    else
      flash[:error] = 'Es ist ein Fehler aufgetreten'
      render :action => :edit
    end
  end
  
  def preview
    @recipient = current_user.email
    
    @newsletter = Newsletter.find(params[:id])
    @newsletter.send_preview_to(current_user)
    flash[:success] = "Newsletter \"#{@newsletter.title}\" wurde an #{@recipient} versandt!"
    
    redirect_to vrame_mailer_newsletters_path
  end
  
  def schedule
    @newsletter = Newsletter.find(params[:id])
    @newsletter.schedule_now!
    
    flash[:success] = "Newsletter \"#{@newsletter.title}\" wurde an alle Abonnenten versandt!"
    
    redirect_to vrame_mailer_newsletters_path
  end
end