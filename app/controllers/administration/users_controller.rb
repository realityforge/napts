class Administration::UsersController < Administration::BaseController
  include AuthHelper
  def new
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
    @users = User.find_all
  end
  
  def update_role
    @other_user = User.find(params[:id])
    @subjects = Subject.find(:all)
  end
  
  def make_demonstrator
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
    @other_user = User.find(params[:id])
    @other_user.administrator = params[:admin]
    if ! @other_user.save
      flash[:alert] = "Update not successful"
    end
    redirect_to( :action => 'list' )
  end
  
  def make_educator
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
    User.find(params[:id]).destroy
    redirect_to( :controller => 'users', :action => 'list' )
  end
end
