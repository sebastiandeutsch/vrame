class DocumentsController < ApplicationController
  def show
    @document = Document.find(params[:id])
    
    # Emit documents with JSON store data mixed in
    @public_document = @document.to_hash
    
    respond_to do |format|
      format.xml  { render :xml  => @public_document }
      format.json { render :json => @public_document }
    end
  end
end