class Vrame::CategoriesController < Vrame::VrameController
  
  def index
    @categories = Category.roots
    
    if params[:category_id]
      @active_category = Category.find(params[:category_id])
      @documents = @active_category.documents
    else
      if session["last_tab_id"]
        logger.info(session.inspect);
        @active_category = Category.find(session["#{session["last_tab_id"]}_category_id"])
        @documents = @active_category.documents
      else
        if @categories.first
          @active_category = @categories.first
          @documents = @active_category.documents
        else
          @active_category = nil
          @documents = []
        end 
      end
    end
  end
  
  def sort
    @category = Category.find(params[:id])
    
    params[:document].each_with_index do |id, i|
      document = Document.find_by_id(id)
      if document.category_id == @category.id
        document.position = i
        document.save
      end
    end
    
    render :text => 'ok'
  end
  
  def new
    @category = Category.new
    if params[:category_id]
      @category.parent = Category.find(params[:category_id])
    end
    
    @breadcrumbs = [{ :title => 'Kategorien', :url => vrame_categories_path }]
    @category.ancestors.reverse.each { |a| @breadcrumbs << { :title => a.title, :url => vrame_category_path(a) } }
  end
  
  def create
    # Hash mapping workaround
    params[:category][:schema] = { 'fields' => params[:fields] || {} }
    params[:category][:meta]   = { 'values' => params[:meta]   || {} }
    
    @category = Category.new(params[:category])
    
    if @category.save
      flash[:success] = 'Kategorie angelegt'
      redirect_to vrame_categories_path + "#category-#{@category.to_param}"
    else
      flash[:error] = 'Dokument konnte nicht angelegt werden'
      render :action => :new
    end
 end
  
  def edit
    @category = Category.find(params[:id])
  end
  
  def update
    @category = Category.find(params[:id])
    
    # Hash mapping workaround
    params[:category][:schema] = { 'fields' => params[:fields] || {} }
    params[:category][:meta]   = { 'values' => params[:meta]   || {} }
    
    if @category.update_attributes(params[:category])
      flash[:success] = 'Die Kategorie wurde aktualisiert'
      redirect_to vrame_categories_path + "#category-#{@category.to_param}"
    else
      flash[:error] = 'Es ist ein Fehler aufgetreten'
      render :action => :edit
    end
  end
  
  def destroy
    @category = Category.find(params[:id])
    if @category.destroy
      flash[:success] = 'Die Kategorie wurde gelöscht'
      redirect_to vrame_categories_path + (@category.parent ? "#category-#{@category.parent.to_param}" : "")
    else
      flash[:error] = 'Die Kategorie konnte nicht gelöscht werden'  #TODO Error Messages hierhin
      redirect_to vrame_categories_path + "#category-#{@category.to_param}"
    end
  end  
  
  def order_up
    @category = Category.find(params[:id])
    @category.move_higher
    
    redirect_to vrame_categories_path + "#category-#{@category.to_param}"
  end
  
  def order_down
    @category = Category.find(params[:id])
    @category.move_lower
    
    redirect_to vrame_categories_path + "#category-#{@category.to_param}"
  end
  
  def publish
    @category = Category.find(params[:id])
    @category.publish
    
    redirect_to vrame_categories_path + "#category-#{@category.to_param}"
  end
  
  def unpublish
    @category = Category.find(params[:id])
    @category.unpublish
    
    redirect_to vrame_categories_path + "#category-#{@category.to_param}"
  end
end