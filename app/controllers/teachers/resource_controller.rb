class Teachers::ResourceController < Teachers::BaseController
  verify :method => :post, :only => %w( destroy )
  verify :method => :get, :only => %w( show list )
  
  def list
    if params[:q]
      conditions = ['subject_group_id = ? AND name LIKE ?',
                    current_subject.subject_group_id, "%#{params[:q]}%" ]
    else
      conditions = ['subject_group_id = ?', current_subject.subject_group_id ]
    end
    @resource_pages, @resources = paginate( :resources, 
                                            :conditions => conditions,
					    :order_by => 'name',
					    :per_page => 10 )
  end
  
  def new
    @resource = Resource.new(params[:resource]) 
    if request.post?
      @resource.subject_group_id = current_subject.subject_group_id
      if @resource.save
        flash[:notice] = 'Resource was successfully created.'
	redirect_to( :action => 'show', :id => @resource )
      else
        flash[:alert] = 'Resource could not be created.'
      end
    end
  end
  
  def show
    @resource = Resource.find(params[:id])
  end
  
  def edit
    @resource = Resource.find(params[:id])
    if request.post?
      if @resource.update_attributes(params[:resource])
        flash[:notice] = 'Resource successfully updated'
	redirect_to( :action => 'show', :id => @resource )
      end
    end
  end
  
  def picture
    @resource = Resource.find(params[:id])
    send_data(@resource.resource_data.data, 
              :filename => @resource.name,
	      :type => @resource.content_type,
	      :disposition => 'inline' )
  end
  
  def download
    @resource = Resource.find(params[:id])
    send_data(@resource.resource_data.data,
              :filename => @resource.name,
	      :type => @resource.content_type,
	      :disposition => 'attachment' )
	     
  end
  
  def destroy
    Resource.find(params[:id]).destroy
    flash[:notice] = 'Resource was successfully deleted.'
    redirect_to( :action => 'list' )
  end
end
