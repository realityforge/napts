class Teachers::UserController < Teachers::BaseController

  def list
    @demonstrators = current_subject.demonstrators 
  end
  
  def list_users
    if params[:q]
      conditions = ['id NOT IN (SELECT user_id FROM demonstrators WHERE subject_id = ?) AND users.name LIKE ?',
                     current_subject.id, "%#{params[:q]}%"]
    else
      conditions = ['id NOT IN (SELECT user_id FROM demonstrators WHERE subject_id = ?)', current_subject.id]
    end
    @user_pages, @users = paginate( :users,
                                    :conditions => conditions,
				    :order_by => 'name',
				    :per_page => 20 )
  end
  
  def add_demonstrator
    @user = User.find(params[:id])
    current_subject.demonstrators << @user
    flash[:notice] = 'Demonstrator was successfully created.'
    redirect_to(:action => 'list_users', :q => params[:q], :page => params[:page]) 
  end
  
  def remove_demonstrator
    @user = User.find(params[:id])
    current_subject.demonstrators.delete(@user)
    flash[:notice] = 'Demonstrator was successfully removed from Subject.'
    redirect_to(:action => 'list')
  end
  
end