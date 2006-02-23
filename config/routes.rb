ActionController::Routing::Routes.draw do |map|
  map.connect '', :controller => 'login', :action => 'login'
  map.connect '/students/preview/resource/:id/:position/:name', :controller => 'students/preview', :action => 'resource'
  map.connect '/students/quiz_attempt/resource/:id/:position/:name', :controller => 'students/quiz_attempt', :action => 'resource'
  map.connect '/students/results/resource/:id/:position/:name', :controller => 'students/results', :action => 'resource'
  map.connect '/teachers/question/resource/:id/:name', :controller => 'teachers/question', :action => 'resource'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
