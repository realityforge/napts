class Admins::SubjectGroupController < Admins::BaseController
  verify :method => :post, :only => %w( destroy )
  verify :method => :get, :only => %w( list )

  def list
    conditions = params[:q] ? ['name LIKE ?', "%#{params[:q]}%"] : '1 = 1'
    @subject_group_pages, @subject_groups = paginate( :subject_groups,
                                                      :conditions => conditions,
                                                      :order_by => 'name',
                                                      :per_page => 10 )
  end

  def new
    @subject_group = SubjectGroup.new(params[:subject_group])
    if request.post?
      if @subject_group.save
        flash[:notice] = 'Subject group was successfully created.'
        redirect_to(:action => 'list')
      end
    end
  end

  def edit
    @subject_group = SubjectGroup.find(params[:id])
    if request.post?
      if @subject_group.update_attributes(params[:subject_group])
        flash[:notice] = 'Subject group was successfully updated.'
        redirect_to(:action => 'list')
      end
    end
  end

  def destroy
    SubjectGroup.find(params[:id]).destroy
    flash[:notice] = 'Subject group was successfully deleted.'
    redirect_to(:action => 'list', :q => params[:q], :page => params[:page])
  end
end
