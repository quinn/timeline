ActionController::Routing::Routes.draw do |map|
  map.resources :entries
  map.root :controller => "entries"
  map.report "reports", :controller => 'entries', :action => 'reports'
  
  map.resource :session
end
