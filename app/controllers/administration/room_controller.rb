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
  
  def add_computers
    @room = Room.find(params[:id])
    if request.post?
    computer = @room.computers.create( :room_id => params[:id], 
                                       :ip_address => params[:computer][:ip_address])
      if ! computer.valid?
        flash[:alert] = 'computer could not be saved'
      else
        flash[:notice] = 'Computer successfully created'
      end
    end
  end
end
