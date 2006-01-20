class Admins::SubjectGroupController < Admins::BaseController
  def list
    @subject_groups = SubjectGroup.find(:all)
  end
  
  def new
    @subject_group = SubjectGroup.new(params[:subject_group])
    if request.post?
      if ! @subject_group.save
        flash[:alert] = 'Subject group could not be created'
      else
        flash[:notice] = 'Subject group was successfully created'
	redirect_to( :action => 'list' )
      end
    end
  end
  
  def edit
    @subject_group = SubjectGroup.find(params[:id])
    if request.post?
      if ! @subject_group.update_attributes(params[:subject_group])
        flash[:alert] = 'Subject group could not be updated'
      else
        flash[:notice] = 'Subject group was successfully updated'
	redirect_to( :action => 'list' )
      end
    end
  end
  
  def destroy
    SubjectGroup.find(params[:id]).destroy
    redirect_to( :action => 'list' )
  end
end
