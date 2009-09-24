class CategoriesController < ApplicationController
  
  def index
    if params[:category_id]
      # Show subcategories from given category
      
      @category = Category.published.find(params[:category_id])
      
      # Filter confidential and unwanted attributes
      @public_categories = @category.children.published.map(&:to_public_hash)
        
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
    @category = Category.published.find(params[:id])
    
    # Redirect permanently to the most recent slug if given slug is outdated
    if @category.found_using_outdated_friendly_id?
      redirect_to @category, :status => 301
      return
    end
    
    # Filter confidential and unwanted attributes
    @public_category = @category.to_public_hash
    
    respond_to do |format|
      format.html do
        @documents = @category.documents.published
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