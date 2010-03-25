ActionController::Routing::Routes.draw do |map|

  map.resources :streams
  map.root :controller => "welcome"
  
end
