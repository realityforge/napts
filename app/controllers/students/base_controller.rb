class Students::BaseController < ApplicationController
  before_filter :verify_student

  helper_method :get_navigation_links

protected
  def get_navigation_links
    links = []
    is_selected = controller_name == 'subject' && @action_name == 'list'
    links << Link.new('Subjects',
                      {:controller => '/students/subject', :action => 'list'},
                      {:title => 'Browse Subjects'},
                      {:selected => is_selected}).freeze
    is_selected = controller_name == 'quiz_attempt' && @action_name == 'list'
    links << Link.new('Active Quizzes',
                      {:controller => '/students/quiz_attempt', :action => 'list'},
                      {:title => 'Browse Quizzes currently active.'},
                      {:selected => is_selected}).freeze
    links
  end

private
  def verify_student
    raise Napts::SecurityError unless session[:role] == :student
  end
end
