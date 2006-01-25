ActionController::Routing::Routes.draw do |map|
  map.connect '', :controller => 'login', :action => 'login'
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
