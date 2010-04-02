ActionController::Routing::Routes.draw do |map|

  map.resources :streams
  map.resources :events
  map.root :controller => "welcome"
  
end
