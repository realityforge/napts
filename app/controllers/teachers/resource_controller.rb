class Teachers::ResourceController < Teachers::BaseController
  verify :method => :post, :only => %w( destroy )
  verify :method => :get, :only => %w( show list view )
  
  def list
    if params[:q]
      conditions = ['subject_group_id = ? AND name LIKE ?',
                    current_subject.subject_group_id, "%#{params[:q]}%" ]
    else
      conditions = ['subject_group_id = ?', current_subject.subject_group_id ]
    end
    @resource_pages, @resources = paginate(:resources, 
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
      end
    end
  end
  
  def show
    @resource = find_resource(params[:id])
  end
  
  def edit
    @resource = find_resource(params[:id])
    if request.post?
      if @resource.update_attributes(params[:resource])
        flash[:notice] = 'Resource was successfully updated.'
	redirect_to( :action => 'show', :id => @resource )
      end
    end
  end

  def view
    disposition = (params[:disposition] == 'download') ? 'download' : 'inline'
    resource = find_resource(params[:id])
    send_data(resource.resource_data.data, 
              :filename => resource.name,
	      :type => resource.content_type,
	      :disposition => disposition )
  end

  def destroy
    find_resource(params[:id]).destroy
    flash[:notice] = 'Resource was successfully deleted.'
    redirect_to(:action => 'list', :q => params[:q], :page => params[:page])
  end

private

  def find_resource(resource_id)
    resource = Resource.find(resource_id,
                              :select => 'resources.*',
                              :conditions => [ 'resources.subject_group_id = ?', current_subject.subject_group_id],
                              :readonly => false)
    raise ActiveRecord::RecordNotFound, "Couldn't find Resource with id = #{params[:id]} AND subject_group_id = #{current_subject.subject_group_id}" unless resource
    resource
  end
end
