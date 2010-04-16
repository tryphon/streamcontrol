ActionController::Routing::Routes.draw do |map|

  map.resources :streams
  map.resources :events
  map.resource :input
  map.resource :dashboard
  map.resources :monitorings

  map.root :controller => "welcome"
  
end
