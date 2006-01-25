class LoginController < ApplicationController
  def login
    reset_session
    if request.get?
      @subjects = Subject.find_all_sorted
    elsif request.post?
      user = User.authenticate(params[:username],params[:password])
      if user.nil?
        flash[:alert] = 'Invalid user or password'
        redirect_to( :action => 'login' )
      else
        role = get_verified_role(user,params[:type],params[:subject_id].to_i)
        if role.nil?
          flash[:alert] = 'Access Denied'
          redirect_to( :action => 'login' )
        else
          session[:subject_id] = Subject.find(params[:subject_id]).id if requires_subject?(role)
          session[:user_id] = user.id
          session[:role] = role
          if role == :demonstrator 
            redirect_to(:controller => '/demonstrators/quiz', :action => 'list')
          elsif role == :administrator 
            redirect_to(:controller => '/admins/subject', :action => 'list')
          elsif role == :student 
            redirect_to(:controller => '/students/subject', :action => 'list')
          else
            redirect_to(:controller => 'welcome', :action => 'index')
          end
        end
      end
    end
  end
  
  def logout
    reset_session
    flash[:notice] = 'Logged out'
    redirect_to( :action => 'login' )
  end
    
protected
  def is_secure?
    return !(action_name == 'login' || action_name == 'logout')
  end
end
