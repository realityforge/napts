class Admins::BaseController < ApplicationController
  before_filter( :verify_admin )

protected
  def get_navigation_links
    links = []
    is_selected = controller_name == 'subject' && @action_name == 'list'
    links << Link.new('Subjects',
                      {:controller => '/admins/subject', :action => 'list'},
                      {:title => 'Add, modify or remove subjects'},
                      {:selected => is_selected}).freeze
    is_selected = controller_name == 'subject_group' && @action_name == 'list'
    links << Link.new('Subject Groups',
                      {:controller => '/admins/subject_group', :action => 'list'},
                      {:title => 'Add, modify or delete subject groups'},
                      {:selected => is_selected}).freeze
    is_selected = controller_name == 'user' && @action_name == 'list'
    links << Link.new('Users',
                      {:controller => '/admins/user', :action => 'list'},
                      {:title => 'Add, modify or remove users'},
                      {:selected => is_selected}).freeze
    is_selected = controller_name == 'room' && @action_name == 'list'
    links << Link.new('Rooms',
                      {:controller => '/admins/room', :action => 'list'},
                      {:title => 'Add, modify or remove rooms'},
                      {:selected => is_selected}).freeze
    links
  end

private
  def verify_admin
    raise Napts::SecurityError unless session[:role] == :administrator
    raise Napts::SecurityError unless current_user.administrator?
  end
end
