class Vrame::DocumentsController < Vrame::VrameController
  def index
    per_page = params[:per_page] || 50
    
    @documents = Document.paginate :page => params[:page], :per_page => per_page
  end
  
  def new
    @category = Category.find(params[:category_id])
      
    @document = @category.documents.build
    
    @breadcrumbs = [{ :title => 'Kategorien', :url => vrame_categories_path}]
    (@category.ancestors << @category).each { |a| @breadcrumbs << { :title => a.title, :url => vrame_category_path(a) } }
  end
  
  def create
    @category = Category.find(params[:category_id])
    
    @document = @category.documents.build(params[:document])

    if @document.save
      flash[:success] = 'Dokument angelegt'
      redirect_to vrame_categories_path
    else
      flash[:error] = 'Dokument konnte nicht angelegt werden'
      redirect_to vrame_categories_path
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
      redirect_to vrame_categories_path
    else
      flash[:error] = 'Es ist ein Fehler aufgetreten'
      render :action => :edit
    end    
  end
  
  def destroy
    @document = Document.find(params[:id])
    if @document.destroy
      flash[:success] = 'Das Dokument wurde gelöscht'
    else
      flash[:error] = 'Das Dokument konnte nicht gelöscht werden'  #TODO Error Messages hierhin
    end
    redirect_to :back
  end  
  
  def order_up
    @document = Document.find(params[:id])
    @document_top = Document.with_parent(@document).order_before(@document.order_index)[0]
    
    document_order_index = @document.order_index
    document_top_order_index = @document_top.order_index
    
    @document.order_index = document_top_order_index
    @document.save
    
    @document_top.order_index = document_order_index
    @document_top.save
    
    redirect_to :back
  end
  
  def order_down
    @document = Document.find(params[:id])
    @document_after = Document.with_parent(@document).order_after(@document.order_index)[0]
    
    document_order_index = @document.order_index
    document_after_order_index = @document_after.order_index
    
    @document.order_index = document_after_order_index
    @document.save
    
    @document_after.order_index = document_order_index
    @document_after.save
    
    redirect_to :back
  end
end