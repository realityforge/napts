class Administration::SubjectsController < Administration::BaseController
  def index
    list
    render( :action => 'list' )
  end
  
   def list
    @subject_pages, @subjects = paginate( :subjects, :per_page => 10 )
  end
  
  def new
    @subject = Subject.new
  end
  
  def create
    @subject = Subject.new(params[:subject])
    if @subject.save
      flash[:notice] = 'Subject was successfully created.'
      redirect_to( :action => 'list' )
    else
      render( :action => 'new' )
    end
  end
  
  def edit
    @subject = Subject.find(params[:id])
  end
  
  def update
    @subject = Subject.find(params[:id])
    if @subject.update_attributes(params[:subject])
      flash[:notice] = 'Subject was successfully updated.'
      redirect_to( :action => 'list', :id => @subject )
    else
      render( :action => 'edit' )
    end
  end

  def destroy
    Subject.find(params[:id]).destroy
    redirect_to( :action => 'list' )
  end
end