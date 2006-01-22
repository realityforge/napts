class Admins::UserController < Admins::BaseController
  verify :method => :post, :only => %w( destroy toggle_admin_status )
  verify :method => :get, :only => %w( show list )

  def new
    @user = User.new(params[:user])
    if request.post?
      if @user.save
        flash[:notice] = 'User was successfully added.'
        redirect_to(:action => 'list', :q => params[:q], :page => params[:page])
      end
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def list
    conditions = params[:q] ? ['name LIKE ?', "%#{params[:q]}%"] : '1 = 1'
    @user_pages, @users = paginate( :users, 
                                    :conditions => conditions,
                                    :order_by => 'name',
                                    :per_page => 10 )
  end

  def toggle_admin_status
    @user = User.find(params[:id])
    @user.administrator = params[:admin_status] == 'true'
    @user.save!
    flash[:notice] = 'Admin status successfully updated for User.'
    redirect_to(:action => 'list', :q => params[:q], :page => params[:page])
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:notice] = 'User was successfully deleted.'
    redirect_to(:action => 'list', :q => params[:q], :page => params[:page])
  end
end
