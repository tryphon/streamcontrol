ActionController::Routing::Routes.draw do |map|

  map.resource :stream
  map.root :controller => "welcome"
  
end
