class Vrame::CategoriesController < Vrame::VrameController
  def index
    per_page = params[:per_page] || 50
    
    @categories = Category.roots.paginate :page => params[:page], :per_page => per_page
    
    @ancestors = []
    
    render :show
  end
  
  def show
    per_page = params[:per_page] || 50
    
    @category = Category.find(params[:id])
    @categories = @category.children.paginate :page => params[:page], :per_page => per_page
    
    @breadcrumbs = [{ :title => 'Kategorien', :url => vrame_categories_path}]
    @category.ancestors.each { |a| @breadcrumbs << { :title => a.title, :url => vrame_category_path(a) } }
  end
  
  def new
    
  end
  
  def edit
    @category = Category.find(params[:id])
  end
  
  def update
    @category = Category.find(params[:id])
    
    # Hash mapping workaround
    params[:category][:schema] = params[:schema]
    
    # Empty default values
    params[:category][:schema] ||= []
    params[:category][:meta] ||= {}

    if @category.update_attributes(params[:category])
      flash[:success] = 'Die Kategorie wurde aktualisiert'
      redirect_to :action => :index
    else
      flash[:error] = 'Es ist ein Fehler aufgetreten'
      render :action => :edit
    end    
  end  
  
  def create
    @category = Category.new(params[:category])
    if @category.save
      flash[:success] = 'Kategorie angelegt'
      redirect_to :action => :index
    else
      flash[:error] = 'Dokument konnte nicht angelegt werden'
      render :new
    end
 end
  
  def destroy
    @category = Category.find(params[:id])
    if @category.destroy
      flash[:success] = 'Die Kategorie wurde gelöscht'
    else
      flash[:error] = 'Die Kategorie konnte nicht gelöscht werden'  #TODO Error Messages hierhin
    end
    redirect_to :action => :index
  end  
  
  def order_up
    @category = Category.find(params[:id])
    @category_top = Category.with_parent(@category).order_before(@category.order_index)[0]
    
    category_order_index = @category.order_index
    category_top_order_index = @category_top.order_index
    
    @category.order_index = category_top_order_index
    @category.save
    
    @category_top.order_index = category_order_index
    @category_top.save
    
    redirect_to :back
  end
  
  def order_down
    @category = Category.find(params[:id])
    @category_after = Category.with_parent(@category).order_after(@category.order_index)[0]
    
    category_order_index = @category.order_index
    category_after_order_index = @category_after.order_index
    
    @category.order_index = category_after_order_index
    @category.save
    
    @category_after.order_index = category_order_index
    @category_after.save
    
    redirect_to :back
  end
end