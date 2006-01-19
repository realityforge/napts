class Demonstrators::BaseController < ApplicationController
  before_filter :verify_demonstrator

  helper_method :get_navigation_links

protected
  def get_navigation_links
    links = []
    is_selected = controller_name == 'quiz' && @action_name == 'list'
    links << MenuHelper::Link.new('Home',
                      {:controller => '/demonstrators/quiz', :action => 'list'},
                      {:title => 'Browse Quizzes for Subject'},
                      {:selected => is_selected}).freeze
    if @quiz
      is_selected = controller_name == 'quiz' && @action_name == 'show'
      links << MenuHelper::Link.new('Quiz',
                        {:controller => '/demonstrators/quiz', :action => 'show', :id => @quiz},
                        {:title => 'Browse Quiz'},
                        {:selected => is_selected}).freeze
    end
    links
  end

private
  def verify_demonstrator
    raise Napts::SecurityError unless current_user.demonstrator_for?(current_subject_id)
  end
end
