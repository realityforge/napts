class UsersController < ApplicationController
  include AuthHelper
  def new
    verify_admin
    if request.get?
      @user = User.new
    else
      @user = User.new(params[:user])
      if @user.save
        flash[:notice] = "User #{@user.username} created"
        redirect_to( :action => 'list' )
      else
        flash[:alert] = "not created"
      end
    end
  end
  
  def list
    verify_admin
    @users = User.find_all
  end
  
  def update_role
    verify_admin
    @other_user = User.find(params[:id])
    @subjects = Subject.find(:all)
  end
  
  def make_demonstrator
    verify_admin
    @other_user = User.find(params[:id])
    @subject = Subject.find(params[:subject_id])
    if params[:value]
      @other_user.demonstrates_for << @subject
    else
      @other_user.demonstrates_for.delete( @subject )
    end
    redirect_to( :action => 'update_role', :id => @other_user.id )
  end
  
  def make_admin
    verify_admin
    @other_user = User.find(params[:id])
    @other_user.administrator = params[:admin]
    if ! @other_user.save
      flash[:alert] = "Update not successful"
    end
    redirect_to( :action => 'list' )
  end
  
  def make_educator
    verify_admin
    @other_user = User.find(params[:id])
    @subject = Subject.find(params[:subject_id])
    if params[:value]
      @other_user.educates_for << @subject
    else
      @other_user.educates_for.delete( @subject )
    end
    redirect_to( :action => 'update_role', :id => @other_user.id )
  end
  
  def delete
    verify_admin
    User.find(params[:id]).destroy
    redirect_to( :controller => 'users', :action => 'list' )
  end
  
end
