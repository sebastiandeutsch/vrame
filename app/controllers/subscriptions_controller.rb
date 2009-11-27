class SubscriptionsController < ApplicationController
  def create
    @subscription = Subscription.create(params[:subscription])
    
    if @subscription.save
      flash[:success] = 'Newsletter-Abonnement: Bestätigungsmail wurde versandt'
      #redirect_to :root_path
    else
      flash[:error] = 'Newsletter-Abonnement konnte nicht angelegt werden'
      redirect_to :back
    end
  end
  
  def confirm
    @subscription = Subscription.find_by_token(params[:id])
    @subscription.confirm!
    flash[:success] = 'Newsletter-Abonnement wurde erfolgreich hinzugefügt!'
    redirect_to root_path
  end
  
  def unsubscribe
    @subscription = Subscription.find_by_token(params[:id])
    if @subscription.destroy
      flash[:success] = 'Adresse erfolgreich von Empfängerliste entfernt!'
    else
      flash[:error] = 'Adresse konnte nicht gelöscht werden!'
    end
    redirect_to root_path
  end
end