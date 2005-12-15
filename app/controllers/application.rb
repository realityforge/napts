# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  helper :view_debug
  helper :menu
  helper_method :authenticated?

  before_filter :check_authentication

protected

  def is_secure?
    true
  end

  def authenticated?
    nil != session[:user_id]
  end

private

  def check_authentication
    authorize if is_secure?
  end
  
  def authorize
    if session[:user_id]
      @user = User.find(session[:user_id])
    else 
      flash[:notice] = 'Please log in'
      redirect_to(:controller => "login", :action => "login")
    end
  end
end
