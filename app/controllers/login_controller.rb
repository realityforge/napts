class LoginController < ApplicationController
  def add_user
    if request.get?
      @user = User.new
    else
      @user = User.new(params[:user])
      if @user.save
        flash[:notice] = "User #{@user.username} created"
        redirect_to( :controller => 'quizzes', :action => 'list' )
      else
        flash[:alert] = "not created"
      end
    end
  end
  
  def login
    if request.get?
      reset_session
      session[:user_id] = nil
      @user = User.new
    else
      @user = User.new(params[:user])
      logged_in_user = @user.try_to_login
      if logged_in_user
        session[:user_id] = logged_in_user.id
	redirect_to( :controller => 'quizzes', :action => 'list' )
      else
        flash[:alert] = "invalid username/password combination"
      end
    end
  end
  
  def logout
    reset_session
    session
    flash[:notice] = "Logged out"
    redirect_to( :action => 'login' )
  end
  
  def list_users
    @users = User.find_all
  end
  
  def delete
    User.find(params[:id]).destroy
    redirect_to( :action => 'list_users' )
  end
  
protected
  def is_secure?
    return !( action_name == 'login' || action_name == 'logout' )
  end
end
