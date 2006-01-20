class Admins::UserController < Admins::BaseController
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
    @user = User.find(params[:id])
    @subjects = Subject.find(:all)
  end

  def make_demonstrator
    @user = User.find(params[:id])
    @subject = Subject.find(params[:subject_id])
    if params[:value]
      @user.demonstrates_for << @subject
    else
      @user.demonstrates_for.delete( @subject )
    end
    redirect_to( :action => 'update_role', :id => @user.id )
  end

  def make_admin
    @user = User.find(params[:id])
    @user.administrator = params[:admin]
    if ! @user.save
      flash[:alert] = "Update not successful"
    end
    redirect_to( :action => 'list' )
  end

  def make_teacher
    @user = User.find(params[:id])
    @subject = Subject.find(params[:subject_id])
    if params[:value]
      @user.teaches << @subject
    else
      @user.teaches.delete( @subject )
    end
    redirect_to( :action => 'update_role', :id => @user.id )
  end

  def delete
    User.find(params[:id]).destroy
    redirect_to( :action => 'list' )
  end
end
