class Vrame::VrameController < ApplicationController
  layout 'vrame'
  
  before_filter :require_user

  def switch_language
    @current_language = Language.find(params[:id])
    session["vrame_backend_language_id"] = @current_language.id
    
    redirect_to vrame_root_path
  end
  
private
  def select_language
    if session["vrame_backend_language_id"]
      @current_language = Language.find(session["vrame_backend_language_id"])
    else
      @current_language = Language.all.first
    end
    
    raise NoLanguageInDatabaseError, "You have to add a language to the database" if @current_language.nil?
    session["vrame_backend_language_id"] = @current_language.id

    true
  end
end