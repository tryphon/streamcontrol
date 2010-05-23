ActionController::Routing::Routes.draw do |map|

  map.resources :streams, :member => { :toggle => :put }
  map.resources :events
  map.resource :input
  map.resource :dashboard
  map.resources :monitorings
  map.resources :releases, :member => { :download => :get, :install => :get, :description => :get }

  map.root :controller => "welcome"
  
end
