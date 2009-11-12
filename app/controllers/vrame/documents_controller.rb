class Vrame::DocumentsController < Vrame::VrameController
  
  def index
    session["vrame_backend_#{current_language.id}_category_id"] = params[:category_id]
    
    @category = Category.find(params[:category_id])
    @documents = @category.documents
    
    render :partial => 'vrame/categories/documents', :locals => { :documents => @documents, :category => @category }
  end
  
  def new
    @category = Category.by_language(current_language).find(params[:category_id])
      
    @document = @category.documents.build(:language_id => current_language.id)
    
    @breadcrumbs = [{ :title => 'Kategorien', :url => vrame_categories_path }] # @TODO This belongs in a helper
    @category.ancestors.reverse.push(@category).each { |a| @breadcrumbs << { :title => a.title, :url => vrame_category_path(a) } }
  end
  
  def create
    @category = Category.find(params[:category_id])
    
    @document = Document.new(params[:document].merge({ :category => @category }))
    
    if @document.save
      flash[:success] = 'Dokument angelegt'
      redirect_to vrame_categories_path + "#document-#{@document.to_param}"
    else
      flash[:error] = 'Dokument konnte nicht angelegt werden'
      @breadcrumbs = [{ :title => 'Kategorien', :url => vrame_categories_path }]
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
    
    redirect_to vrame_categories_path + "#document-#{@document.to_param}"
  end
  
  def unpublish
    @document = Document.find(params[:id])
    @document.unpublish
    
    redirect_to vrame_categories_path + "#document-#{@document.to_param}"
  end
end