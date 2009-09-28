class Vrame::DocumentsController < Vrame::VrameController
  
  def index
    per_page = params[:per_page] || 50
    @documents = Document.paginate :page => params[:page], :per_page => per_page
  end
  
  def new
    @category = Category.find(params[:category_id])
      
    @document = @category.documents.build
    
    @breadcrumbs = [{ :title => 'Kategorien', :url => vrame_categories_path }]
    @category.ancestors.reverse.push(@category).each { |a| @breadcrumbs << { :title => a.title, :url => vrame_category_path(a) } }
  end
  
  def create
    @category = Category.find(params[:category_id])
    
    @document = @category.documents.build(params[:document])
    
    if @document.save
      flash[:success] = 'Dokument angelegt'
      redirect_to vrame_categories_path + "#document-#{@document.to_param}"
    else
      flash[:error] = 'Dokument konnte nicht angelegt werden'
      render :action => :new
    end
  end
  
  def edit
    @document = Document.find(params[:id])
    @category = @document.category
    
    @collections = Hash.new # { |hash, key| hash[key] = @document.collections.build }
    @document.collections.each { |c| @collections[c.id] = c }
  end
  
  def update
    @document = Document.find(params[:id])
    
    if @document.update_attributes(params[:document])
      flash[:success] = 'Dokument aktualisiert'
      redirect_to vrame_categories_path + "#document-#{@document.to_param}"
    else
      flash[:error] = 'Es ist ein Fehler aufgetreten'
      render :action => :edit
    end
  end
  
  def destroy
    @document = Document.find(params[:id])
    @category = @document.category
    if @document.destroy
      flash[:success] = 'Das Dokument wurde gelöscht'
      redirect_to vrame_categories_path + "#category-#{@category.to_param}"
    else
      flash[:error] = 'Das Dokument konnte nicht gelöscht werden'  #TODO Error Messages hierhin
      redirect_to vrame_categories_path
    end
  end  
  
  def order_up
    @document = Document.find(params[:id])
    @document.move_higher
    
    redirect_to vrame_categories_path + "#document-#{@document.to_param}"
  end
  
  def order_down
    @document = Document.find(params[:id])
    @document.move_lower
    
    redirect_to vrame_categories_path + "#document-#{@document.to_param}"
  end
  
  def publish
    @document = Document.find(params[:id])
    @document.publish
    
    redirect_to vrame_categories_path
  end
  
  def unpublish
    @document = Document.find(params[:id])
    @document.unpublish
    
    redirect_to vrame_categories_path
  end
end