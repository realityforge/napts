class Admins::SubjectController < Admins::BaseController
  verify :method => :post, :only => %w( destroy add_teacher remove_teacher )
  verify :method => :get, :only => %w( show list teachers )

  def list
    conditions = params[:q] ? ['name LIKE ?', "%#{params[:q]}%"] : '1 = 1'
    @subject_pages, @subjects = paginate( :subjects, 
                                          :conditions => conditions,
                                          :order_by => 'name',
                                          :per_page => 10 )
  end
  
  def new
    @groups = SubjectGroup.find_all_sorted
    @subject = Subject.new(params[:subject])
    if request.post?
      if @subject.save
        flash[:notice] = 'Subject was successfully created.'
        redirect_to(:action => 'show', :id => @subject)
      end
    end
  end
  
  def show
    @subject = Subject.find(params[:id])
  end

  def edit
    @subject = Subject.find(params[:id])
    @groups = SubjectGroup.find_all_sorted
    if request.post?
      if @subject.update_attributes(params[:subject])
        flash[:notice] = 'Subject was successfully updated.'
        redirect_to(:action => 'show', :id => @subject)
      end
    end
  end

  def teachers
    @subject = Subject.find(params[:id])
    if params[:q]
      conditions = 
        ['id NOT IN (SELECT user_id FROM teachers WHERE subject_id = ?) AND users.name LIKE ?', 
        @subject.id, 
        "%#{params[:q]}%"]
    else
      conditions = ['id NOT IN (SELECT user_id FROM teachers WHERE subject_id = ?)', @subject.id]
    end
    @user_pages, @users = paginate( :users, 
                                    :conditions => conditions,
                                    :order_by => 'name',
                                    :per_page => 20 )
  end

  def add_teacher
    @subject = Subject.find(params[:id])
    @user = User.find(params[:user_id])
    @subject.teachers << @user
    flash[:notice] = 'Teacher was successfully added to Subject.'
    redirect_to(:action => 'teachers', :id => @subject, :q => params[:q], :page => params[:page])
  end

  def remove_teacher
    @subject = Subject.find(params[:id])
    @user = User.find(params[:user_id])
    @subject.teachers.delete(@user)
    flash[:notice] = 'Teacher was successfully removed from Subject.'
    redirect_to(:action => 'show', :id => @subject)
  end

  def destroy
    Subject.find(params[:id]).destroy
    flash[:notice] = 'Subject was successfully deleted.'
    redirect_to(:action => 'list', :q => params[:q], :page => params[:page])
  end
end
