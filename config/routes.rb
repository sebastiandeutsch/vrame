ActionController::Routing::Routes.draw do |map|
  map.namespace(:vrame) do |vrame|
    # VRAME index
    vrame.root :controller => 'categories', :action => 'index'
    
    # CRUD
    vrame.resources :languages
    vrame.resources :categories, :has_many => [:documents], :member => { :order_up => :get, :order_down => :get }
    vrame.resources :categories, :has_many => [:categories], :only => [:new]
    vrame.resources :documents, :member => { :order_up => :get, :order_down => :get }
    
    #vrame.connect 'categories/:url', :controller => 'categories', :action => :index
    
    # Assets CRUD
    vrame.resources :assets
    #vrame.resources :collections, :has_many => [:assets]
    
    vrame.select_language '/select_language/:id',  :controller => 'vrame', :action => 'select_language'
  end

  map.resources :categories, :has_many => [:documents]
  map.resources :documents
end