class LoginController < ApplicationController
  def login
    if request.get?
      reset_session
    else
      user = User.authenticate(params[:username],params[:password])
      if user
        session[:user_id] = user.id
	redirect_to( :controller => 'subjects', :action => 'list' )
      else
        flash[:alert] = "invalid username/password combination"
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
