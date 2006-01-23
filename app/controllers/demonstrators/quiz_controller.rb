class Demonstrators::QuizController < Demonstrators::BaseController
  verify :method => :get, :only => %w( list show )

  def list
    @quizzes = current_subject.quizzes.find(:all, :order => 'created_at DESC')
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
