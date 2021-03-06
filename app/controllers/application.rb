# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  include AuthHelper

  helper_method :authenticated?
  helper_method :current_user
  helper_method :current_subject
  helper_method :get_navigation_links

  before_filter :check_authentication
  before_filter :force_no_cache

protected

  Link = Struct.new( "Link", :name, :link_options, :html_options, :options ) if ! const_defined?(:Link)

  def get_navigation_links
    nil
  end

  def is_secure?
    true
  end

  def authenticated?
    nil != session[:user_id]
  end

  def current_subject_id
    session[:subject_id]
  end

  def current_subject
    @current_subject = Subject.find(current_subject_id) unless @current_subject
    @current_subject
  end
  def current_user
    @current_user
  end

  def rescue_action(e)
    if e.is_a?(Napts::SecurityError)
      redirect_to(:controller => '/security', :action => 'access_denied')
    else
      super
    end
  end

private

  def force_no_cache
    # set modify date to current timestamp
    response.headers["Last-Modified"] = CGI::rfc1123_date(Time.now)

    # set expiry to back in the past (makes us a bad candidate for caching)
    response.headers["Expires"] = 0

    # HTTP 1.0 (disable caching)
    response.headers["Pragma"] = "no-cache"

    # HTTP 1.1 (disable caching of any kind)
    # HTTP 1.1 'pre-check=0, post-check=0' => (Internet Explorer should always check)
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate, pre-check=0, post-check=0"
  end

  def check_authentication
    is_secure? ? authorize : true
  end

  def authorize
    if session[:user_id]
      begin
        @current_user = User.find(session[:user_id])
      rescue
        flash[:alert] = 'User account deleted.'
        redirect_to(:controller => '/login', :action => 'login')
        false
      end
    else
      flash[:notice] = 'Please log in.'
      redirect_to(:controller => '/login', :action => 'login')
      false
    end
  end
end

module Napts
  # Security error. Controllers throw these in situations where a user is trying to access a
  # function that he is not authorized to access.
  class SecurityError < StandardError
  end
end
