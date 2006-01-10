class LoginController < ApplicationController
  def login
    if request.get?
      reset_session
    else
      user = User.authenticate(params[:username],params[:password])
      if user
        session[:user_id] = user.id
        @role = params[:type]
      	if @role == "Administrator"
	  if user.administrator
	    session[:role] = @role
	    redirect_to( :controller => 'admin', :action => 'home' )
	  else
	    flash[:alert] = "Access denied"
	    redirect_to( :action => 'login' )
	  end
	elsif @role == "Educator"
	  if user.educator?
	    session[:role] = @role
	    redirect_to( :controller => 'quizzes', :action => 'list' )
	  else
	    flash[:alert] = "Access denied"
	    redirect_to( :action => 'login' )
	  end
	elsif @role == "Demonstrator"
	  if user.demonstrator?
	    session[:role] = @role
	    redirect_to( :controller => 'subjects', :action => 'list' )
	  else
	    flash[:alert] = "Access Denied"
	    redirect_to( :action => 'login' )
	  end
	else
	  session[:role] = @role
	  redirect_to( :controller => 'welcome', :action => 'index' )
	end
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
