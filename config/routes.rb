ActionController::Routing::Routes.draw do |map|
  
  # Backend
  
  map.namespace(:vrame) do |vrame|
    # VRAME index
    vrame.root :controller => 'categories', :action => 'index'
    
    # Categories
    vrame.resources :categories, :has_many => [ :documents ], :member => { :edit_eigenschema => :get, :edit_eigenvalues => :get, :order_up => :get, :order_down => :get, :publish => :get, :unpublish => :get, :sort => :post }
    vrame.resources :categories, :has_many => [ :categories ], :only => [ :new ]
    
    # Documents
    vrame.resources :documents, :member => { :order_up => :get, :order_down => :get, :publish => :get, :unpublish => :get  }
    
    # Languages
    vrame.resources :languages
    vrame.switch_language '/switch_language/:id',  :controller => 'vrame', :action => 'switch_language'
    
    # Assets and Collections
    vrame.resources :assets
    vrame.resources :collections, :member => { :rearrange => :get, :sort => :post }
  end

  # Frontend
  map.switch_language     '/switch_language/:id',                        :controller => 'application', :action => 'switch_language'
  
  # Categories
  map.resources :categories, :only => [ :show ]
  map.category_documents  '/categories/:category_id/documents',          :controller => 'documents',   :action => 'index'
  map.category_documents  '/categories/:category_id/documents.:format',  :controller => 'documents',   :action => 'index'
  map.category_categories '/categories/:category_id/categories',         :controller => 'categories',  :action => 'index'
  map.category_categories '/categories/:category_id/categories.:format', :controller => 'categories',  :action => 'index'
  
  # Documents
  map.resources :documents, :only => [ :show ]
  
  # Search
  map.seach     '/search', :controller => 'documents', :action => 'search'
  
  # Assets
  map.download_asset '/assets/:id/download', :controller => 'assets', :action => 'download'
  
end