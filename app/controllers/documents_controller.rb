class DocumentsController < ApplicationController
  def show
    @document = Document.find(params[:id])
    
    @public_document = {
      :title => @document.title
    }.merge(@document.meta)
    
    respond_to do |format|
      format.xml  { render :xml  => @public_document }
      format.json { render :json => @public_document }
    end
  end
end