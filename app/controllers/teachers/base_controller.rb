class Teachers::BaseController < ApplicationController
  before_filter :verify_teacher

protected
  def get_navigation_links
    links = []
    is_selected = controller_name == 'quiz' && @action_name == 'list'
    links << Link.new('Quizzes',
                      {:controller => '/teachers/quiz', :action => 'list'},
                      {:title => 'Browse Quizzes'},
                      {:selected => is_selected}).freeze
    is_selected = controller_name == 'question' && @action_name == 'list'
    links << Link.new('Questions',
                      {:controller => '/teachers/question', :action => 'list'},
                      {:title => 'Browse Questions'},
                      {:selected => is_selected}).freeze
    is_selected = controller_name == 'resource' && @action_name == 'list'
    links << Link.new('Resources',
                      {:controller => '/teachers/resource', :action => 'list'},
                      {:title => 'Browse Resources'},
                      {:selected => is_selected}).freeze
    is_selected = controller_name == 'user' && @action_name == 'list'
    links << Link.new('Demonstrators',
                      {:controller => '/teachers/user', :action => 'list'},
                      {:title => 'Browse Demonstrators'},
                      {:selected => is_selected}).freeze
    links
  end

private
  def verify_teacher
    raise Napts::SecurityError unless session[:role] == :teacher
    raise Napts::SecurityError unless current_user.teaches?(current_subject_id)
  end
end
