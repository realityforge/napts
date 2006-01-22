class Admins::RoomController < Admins::BaseController
  verify :method => :post, :only => %w( destroy )
  verify :method => :get, :only => %w( show list )

  def show
    @room = Room.find(params[:id])
  end
  
  def list
    conditions = params[:q] ? ['name LIKE ?', "%#{params[:q]}%"] : '1 = 1'
    @room_pages, @rooms = paginate( :rooms, 
                                    :conditions => conditions,
                                    :order_by => 'name',
                                    :per_page => 10 )
  end

  def new
    @room = Room.new(params[:room])
    if request.post?
      if @room.save
        flash[:notice] = 'Room was successfully created.'
        redirect_to(:action => 'show', :id => @room)
      end
    end
  end
  
  def edit
    @room = Room.find(params[:id])
    if request.post?
      @room.attributes = params[:room]
      if @room.save
        flash[:notice] = 'Room was successfully updated.'
        redirect_to(:action => 'show', :id => @room)
      end
    end
  end
  
  def destroy
    Room.find(params[:id]).destroy
    flash[:notice] = 'Room was successfully deleted.'
    redirect_to(:action => 'list', :q => params[:q], :page => params[:page])
  end
end
