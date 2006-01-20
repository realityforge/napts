class Admins::BaseController < ApplicationController
  before_filter( :verify_admin )

  helper_method :get_navigation_links

protected
  def get_navigation_links
    links = []
    is_selected = controller_name == 'subjects' && @action_name == 'list'
    links << MenuHelper::Link.new('Subjects',
                                  {:controller => '/admins/subjects', :action => 'list'},
                                  {:title => 'Add, modify or remove subjects'},
                                  {:selected => is_selected}).freeze
    is_selected = controller_name == 'subject_group' && @action_name == 'list'
    links << MenuHelper::Link.new('Subject Groups',
                                  {:controller => '/admins/subject_group', :action => 'list'},
                                  {:title => 'Add, modify or delete subject groups'},
                                  {:selected => is_selected}).freeze
    is_selected = controller_name == 'users' && @action_name == 'list'
    links << MenuHelper::Link.new('Users',
                                  {:controller => '/admins/users', :action => 'list'},
                                  {:title => 'Add, modify or remove users'},
                                  {:selected => is_selected}).freeze
    is_selected = controller_name == 'room' && @action_name == 'list'
    links << MenuHelper::Link.new('Rooms',
                                  {:controller => '/admins/room', :action => 'list'},
                                  {:title => 'Add, modify or remove rooms'},
                                  {:selected => is_selected}).freeze
    links
  end

private
  def verify_admin
    raise Napts::SecurityError unless current_user.administrator?
  end
end
