class Vrame::Mailer::SubscriptionsController < Vrame::VrameController
  def index
    per_page = params[:per_page] || 50
    
    @subscriptions = Subscription.paginate :page => params[:page], :per_page => per_page, :order => :email
  end
  
  def destroy
    @subscription = Subscription.find(params[:id])
    if @subscription.destroy
      flash[:success] = 'Empfänger wurde gelöscht'
    else
      flash[:error] = 'Der Empfänger konnte nicht gelöscht werden'
    end
    redirect_to :action => :index
  end
end