class Administration::RoomController < Administration::BaseController
  def list
    @rooms = Room.find(:all)
  end
  
  def new
    @room = Room.new(params[:room])
    if request.post?
      if ! @room.save
        flash[:alert] = 'Room could not be created'
      else
        flash[:notice] = 'Room successfully created'
	redirect_to( :action => 'list' )
      end
    end
  end
  
  def edit
    @room = Room.find(params[:id])
    if request.post?
      if ! @room.update_attributes(params[:room])
        flash[:alert] = 'Room update not successful'
      else
        flash[:notice] = 'Update successful'
      end
      redirect_to( :action => 'list' )
    end
  end
  
  def destroy
    Room.find(params[:id]).destroy
    redirect_to( :action => 'list' )
  end
end
