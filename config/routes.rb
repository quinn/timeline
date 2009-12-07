ActionController::Routing::Routes.draw do |map|
  map.resources :entries
  map.root :controller => "welcome"
end
