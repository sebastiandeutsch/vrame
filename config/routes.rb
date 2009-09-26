ActionController::Routing::Routes.draw do |map|
  
  # Backend
  
  map.namespace(:vrame) do |vrame|
    # VRAME index
    vrame.root :controller => 'categories', :action => 'index'
    
    # Categories
    vrame.resources :categories, :has_many => [ :documents ], :member => { :order_up => :get, :order_down => :get, :publish => :get, :unpublish => :get }
    vrame.resources :categories, :has_many => [ :categories ], :only => [ :new ]
    
    # Documents
    vrame.resources :documents, :member => { :order_up => :get, :order_down => :get, :order_down => :get, :publish => :get, :unpublish => :get  }
    
    # Languages
    vrame.resources :languages
    vrame.select_language '/select_language/:id',  :controller => 'vrame', :action => 'select_language'
    
    # Assets and Collections
    vrame.resources :assets
    vrame.resources :collections
  end

  # Frontend
  
  # Categories
  map.resources :categories, :only => [ :show ]
  map.category_documents  '/categories/:category_id/documents',          :controller => 'documents',  :action => 'index'
  map.category_documents  '/categories/:category_id/documents.:format',  :controller => 'documents',  :action => 'index'
  map.category_categories '/categories/:category_id/categories',         :controller => 'categories', :action => 'index'
  map.category_categories '/categories/:category_id/categories.:format', :controller => 'categories', :action => 'index'
  
  # Documents
  map.resources :documents, :only => [ :show ]
  map.seach     '/search', :controller => 'documents', :action => 'search'
  
  # Assets
  map.download_asset '/assets/:id/download', :controller => 'assets', :action => 'download'
  
end