ActionController::Routing::Routes.draw do |map|
  map.namespace(:admin) do |admin|
    # Admin index
    admin.root :controller => 'categories', :action => 'index'
    
    # CRUD
    admin.resources :languages
    admin.resources :categories, :has_many => [:documents]
    admin.resources :documents
    
    #admin.connect 'categories/:url', :controller => 'categories', :action => :index
    
    # Assets CRUD
    admin.resources :assets
    #admin.resources :collections, :has_many => [:assets]
    
    admin.select_language '/select_language/:id',  :controller => 'admin', :action => 'select_language'
  end

  map.resources :categories, :has_many => [:documents]
  map.resources :documents
end