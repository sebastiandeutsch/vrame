class CategoriesController < ApplicationController
  
  def index
    if params[:category_id]
      # Show subcategories from given category
      
      @category = Category.find(params[:category_id])
      
      # Filter confidential and unwanted attributes
      @public_categories = @category.children.map(&:to_hash)
        
      respond_to do |format|
        format.json do
          response.headers["Content-Type"] = "text/plain; charset=utf-8"
          render :json => @public_categories
        end
        format.xml do
          render :xml  => @public_categories
        end
      end
      
    else
      # Don't show all categories
      render :text => nil
    end
  end
  
  def show
    @category = Category.find(params[:id])
    redirect_to @category, :status => 301 if @category.found_using_outdated_friendly_id?
    
    # Filter confidential and unwanted attributes
    @public_category = @category.to_hash
    
    respond_to do |format|
      format.html do
        @documents = @category.documents
        unless @category.template.empty?
          render :template => @category.template
        end
      end
      format.json do
        render :json => @public_category
        response.headers["Content-Type"] = "text/plain; charset=utf-8"
      end
      format.xml  do
        render :xml  => @public_category
      end
    end
    
  end
end