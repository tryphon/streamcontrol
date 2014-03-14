# ActionController::Routing::Routes.draw do |map|

#   map.resources :streams, :member => { :toggle => :put }
#   map.resource :metadata, :controller => "metadata"

#   map.resources :events
#   map.resource :dashboard
#   map.resources :monitorings

#   map.root :controller => "welcome"

# end

StreamControl::Application.routes.draw do
  resources :streams do
    member do
      put :toggle
    end
  end

  resource :dashboard
  resources :events
  resource :metadata
  resources :monitorings
  root :to => 'welcome#index'
end
