class DocumentsController < ApplicationController

  def index
    if params[:category_id]
      # Show documents from given category
      
      @category = Category.by_language(current_language).published.find(params[:category_id])
      @documents = @category.documents.published
      
      # Emit documents with JSON store data mixed in
      @public_documents = @documents.map(&:to_public_hash)
        
      respond_to do |format|
        format.json do
          response.headers["Content-Type"] = "text/plain; charset=utf-8"
          render :json => @public_documents
        end
        format.xml do
          render :xml  => @public_documents
        end
      end
        
    else
      # Don't show all documents
      render :text => nil
    end
  end
  
  def show
    
    begin
      @document = Document.by_language(current_language).published.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      raise ActiveRecord::RecordNotFound, "Couldn't find Document with ID=#{params[:id]}, maybe you need to publish it first"
    end
    
    redirect_to @document, :status => 301 if @document.found_using_outdated_friendly_id?
    
    # Emit document with JSON store data mixed in
    @public_document = @document.to_public_hash
    
    respond_to do |format|
      format.json do
        render :json => @public_document
      end
      format.xml do
        render :xml  => @public_document
      end
      format.html do
        @page_title = @document.title
        render(@document.render_options.blank? ? nil : @document.render_options)
      end
    end
  end
  
  def search
    @documents = Document.search(params[:q], language => current_language, :page => params[:page], :per_page => 10)
  end
end