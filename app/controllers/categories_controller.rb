class CategoriesController < ApplicationController
  def show
    @category = Category.find(params[:id])
    
    @public_documents = @category.documents
    
    respond_to do |format|
      format.xml  { render :xml  => @public_documents }
      format.json { render :json => @public_documents }
    end
  end
end