class Demonstrators::QuizController < Demonstrators::BaseController
  verify :method => :post, :only => %w( disable enable )
  verify :method => :get, :only => %w( list show )

  def list
    @quizzes = current_subject.quizzes.find(:all, :order => 'created_at')
  end

  def show
    @quiz = current_subject.quizzes.find(params[:id], :include => 'subject')
  end
  
  def enable_quiz
    @quiz = current_subject.quizzes.find(params[:quiz_id], :include => 'subject')
    @rooms = Room.find(:all)
    if request.post?
      @quiz.active_in.clear
      if params[:room]
        for room in params[:room][:id]
          @quiz.active_in << Room.find(room)
        end
      end
      redirect_to( :action => 'show', :id => @quiz )
    end
  end
end
