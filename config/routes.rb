ActionController::Routing::Routes.draw do |map|
  map.connect '', :controller => 'subjects', :action => 'list'
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
