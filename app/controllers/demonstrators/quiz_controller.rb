class Demonstrators::QuizController < Demonstrators::BaseController
  verify :method => :get, :only => %w( list show list_rooms )
  verify :method => :post, :only => %w( enable_room )

  def list
    if params[:q]
      conditions = ['subject_id = ? AND name LIKE ?', current_subject.id, "%#{params[:q]}%"]
    else
      conditions = ['subject_id = ?', current_subject.id]
    end
    @quiz_pages, @quizzes = paginate( :quizzes, 
                                      :conditions => conditions,
                                      :order_by => 'created_at DESC',
                                      :per_page => 10 )
  end

  def show
    @quiz = current_subject.quizzes.find(params[:id], :include => 'subject')
  end
  
  def list_rooms
    @quiz = current_subject.quizzes.find(params[:id])
    if params[:q]
      conditions = ['name LIKE ?', @quiz.id, "%#{params[:q]}%"]
    else
      conditions = ['1 = 1']
    end
    @room_pages, @rooms = paginate(:room, 
                                   :select => 'rooms.*',
                                   :conditions => conditions,
                                   :order_by => 'name',
                                   :per_page => 10)
  end

  def enable_room
    quiz = current_subject.quizzes.find(params[:id])
    room = Room.find(params[:room_id])
    if params[:enable].to_s == 'true'
      quiz.active_in << room
    else
      quiz.active_in.delete(room)
    end
    flash[:notice] = 'Update of enabled Rooms for Quiz was successful.'
    redirect_to(:action => 'list_rooms', :id => quiz.id, :q => params[:q])
  end
end
