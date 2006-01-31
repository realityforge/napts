class Teachers::ResourceController < Teachers::BaseController
  verify :method => :post, :only => %w( destroy )
  verify :method => :get, :only => %w( show list )
  
  def list
    conditions = params[:q] ? ['name LIKE ?', "%#{params[:q]}%"] : '1 = 1'
    @resource_pages, @resources = paginate( :resources, 
                                            :conditions => conditions,
					    :order_by => 'name',
					    :per_page => 10 )
  end
  
  def new
    @resource = Resource.new(params[:resource])
    if request.post?
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
  
  def download
  end
  
  def destroy
    Resource.find(params[:id]).destroy
    flash[:notice] = 'Resource was successfully deleted.'
    redirect_to( :action => 'list' )
  end
end
