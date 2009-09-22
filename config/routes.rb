ActionController::Routing::Routes.draw do |map|
  
  # Backend
  
  map.namespace(:vrame) do |vrame|
    # VRAME index
    vrame.root :controller => 'categories', :action => 'index'
    
    # CRUD
    vrame.resources :languages
    vrame.resources :categories, :has_many => [ :documents ], :member => { :order_up => :get, :order_down => :get }
    vrame.resources :categories, :has_many => [ :categories ], :only => [ :new ]
    vrame.resources :documents, :member => { :order_up => :get, :order_down => :get }
    
    # Assets CRUD
    vrame.resources :assets
    #vrame.resources :collections, :has_many => [:assets]
    
    vrame.select_language '/select_language/:id',  :controller => 'vrame', :action => 'select_language'
  end

  # Frontend
  
  map.resources :categories, :only => [ :show ]
  map.category_documents  '/categories/:category_id/documents',          :controller => 'documents',  :action => 'index'
  map.category_documents  '/categories/:category_id/documents.:format',  :controller => 'documents',  :action => 'index'
  map.category_categories '/categories/:category_id/categories',         :controller => 'categories', :action => 'index'
  map.category_categories '/categories/:category_id/categories.:format', :controller => 'categories', :action => 'index'
  
  map.resources :documents, :only => [ :show ]
  
  map.download_asset '/assets/:id/download', :controller => 'assets', :action => 'download'
  
end