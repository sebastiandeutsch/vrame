class CategoriesController < ApplicationController
  def show
    @category = Category.find(params[:id])
    
    @documents = @category.documents
    
    # Emit documents with JSON store data mixed in
    @documents_as_hashes = @documents.map { |document| document.to_hash }
    
    respond_to do |format|
      format.html do
        unless @category.template.empty?
          render :template => @category.template
        end
      end
      format.xml  do
        render :xml  => @documents_as_hashes
      end
      format.json do
        render :json => @documents_as_hashes
      end
    end
    
  end
end