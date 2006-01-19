class Administration::SubjectsController < Administration::BaseController

  def list
    @subjects = Subject.find(:all)
  end
  
  def new
    @groups = SubjectGroup.find(:all)
    @subject = Subject.new(params[:subject])
    if request.post?
      if ! @subject.save
        flash[:alert] = 'Subject could not be created'
      else
        flash[:notice] = 'Subject was successfully created.'
        redirect_to( :action => 'list' )
      end
    end
  end
  
  def edit
    @subject = Subject.find(params[:id])
    @groups = SubjectGroup.find(:all)
    if request.post?
      if  ! @subject.update_attributes(params[:subject])
        flash[:alert] = 'Subject could not be updated'
      else
        flash[:notice] = 'Subject was successfully updated.'
        redirect_to( :action => 'list' )
      end
    end
  end

  def destroy
    Subject.find(params[:id]).destroy
    redirect_to( :action => 'list' )
  end
end
