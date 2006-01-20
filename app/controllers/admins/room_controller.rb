class Admins::RoomController < Admins::BaseController
  def list
    @rooms = Room.find(:all)
  end
  
  def new
    @room = Room.new(params[:room])
    if request.post?
      if ! @room.save
        flash[:alert] = 'Room could not be created'
      else
        valid = true
        addys = params[:computer][:ip_address].chomp.split(/\s/)
        addys.each do |line|
          computer = @room.computers.create(:ip_address => line)
	  if ! computer.valid?
	    valid = false
	  end
        end
        if ! valid
          flash[:alert] = 'Not all computers could be saved successfully'
        else
          flash[:notice] = 'Computers successfully created'
        end
        flash[:notice] = 'Room successfully created'
	redirect_to( :action => 'list' )
      end
    end
  end
  
  def edit
    @room = Room.find(params[:id])
    if request.post?
      for computer in params[:computer_ip_addresses]
        Computer.find(computer).destroy
      end
      if ! @room.update_attributes(params[:room])
        flash[:alert] = 'Room update not successful'
      else
        flash[:notice] = 'Update successful'
      end
      redirect_to( :action => 'list' )
    end
  end
  
  def show
    @room = Room.find(params[:id])
  end
  
  def destroy
    Room.find(params[:id]).destroy
    redirect_to( :action => 'list' )
  end
  
  def add_computers
    @room = Room.find(params[:id])
    if request.post?
       valid = true
      addys = params[:computer][:ip_address].chomp.split(/\s/)
      addys.each do |line|
        computer = @room.computers.create(:ip_address => line)
	if ! computer.valid?
	  valid = false
	end
      end
      if ! valid
        flash[:alert] = 'Not all computers could be saved successfully'
      else
        flash[:notice] = 'Computers successfully created'
      end
    end
  end
end
