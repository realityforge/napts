class Admins::SubjectGroupController < Admins::BaseController
  verify :method => :post, :only => %w( destroy )
  verify :method => :get, :only => %w( list )

  def list
    @subject_groups = SubjectGroup.find_all_sorted
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
    redirect_to(:action => 'list')
  end
end
