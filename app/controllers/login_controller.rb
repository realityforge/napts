class LoginController < ApplicationController
  include AuthHelper

  def login
    if request.get?
      reset_session
    else
      user = User.authenticate(params[:username],params[:password])
      if user.nil?
        flash[:alert] = "Invalid user or password"
      else
        role = get_verified_role(user,params[:type])
        if role.nil?
          flash[:alert] = "Access Denied"
          redirect_to( :action => 'login' )
        else
          session[:user_id] = user.id
          session[:role] = role
          redirect_to( :controller => 'welcome', :action => 'index' )
        end
      end
    end
  end
  
  def logout
    reset_session
    flash[:notice] = "Logged out"
    redirect_to( :action => 'login' )
  end
    
protected
  def is_secure?
    return !( action_name == 'login' || action_name == 'logout' )
  end
end
