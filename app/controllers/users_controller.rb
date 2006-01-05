class UsersController < ApplicationController
  def new
    if request.get?
      @user = User.new
    else
      @user = User.new(params[:user])
      if @user.save
        flash[:notice] = "User #{@user.username} created"
        redirect_to( :controller => 'subjects', :action => 'list' )
      else
        flash[:alert] = "not created"
      end
    end
  end
  
  def list
    @users = User.find_all
  end
  
  def delete
    User.find(params[:id]).destroy
    redirect_to( :controller => 'users', :action => 'list' )
  end
end
