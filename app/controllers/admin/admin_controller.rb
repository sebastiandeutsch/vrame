class Admin::AdminController < ApplicationController
  layout "admin_application"
  
  before_filter :require_user
  before_filter :choose_language, :except => :select_language

  def select_language
    session[:admin_current_language_id] = params[:id]
    redirect_to '/admin'
  end
  
private
  def choose_language
    if session[:admin_current_language_id]
      @admin_current_language = Language.find_by_iso3_code(session[:admin_current_language_id])
    else
      @admin_current_language = Language.all.first
    end
    
    if @admin_current_language.nil?
      render :text => 'No languages found please run "rake vrame:bootstrap"'
    else
      session[:admin_current_language_id] = @admin_current_language.iso3_code
    end
  end
end