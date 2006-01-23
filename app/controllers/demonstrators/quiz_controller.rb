class Demonstrators::QuizController < Demonstrators::BaseController
  verify :method => :get, :only => %w( list show )

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
  
  def enable
    @quiz = current_subject.quizzes.find(params[:id])
    if request.get?
      @rooms = Room.find_all_sorted
    elsif request.post?
      @quiz.active_in.clear
      for room_id in params[:room_ids]
        @quiz.active_in << Room.find(room_id)
      end if params[:room_ids]
      flash[:notice] = 'Update of enabled Rooms for Quiz was successful.'
      redirect_to(:action => 'show', :id => @quiz)
    end
  end
end
