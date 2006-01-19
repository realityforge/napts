class Demonstrators::QuizAttemptController < Demonstrators::BaseController
  def list
    @quiz = current_subject.quizzes.find(params[:quiz_id])
    @quiz_attempt_pages, @quiz_attempts = paginate( :quiz_attempt, 
                                                    :include => 'user',
                                                    :conditions => ['quiz_attempts.quiz_id = ?', @quiz.id],
                                                    :order_by => 'users.username',
                                                    :per_page => 20 )
  end

  def reset
    @quiz = current_subject.quizzes.find(params[:quiz_id])
    if ! @quiz.quiz_attempts.find(params[:quiz_attempt_id]).destroy
      flash[:alert] = 'Unable to reset user.'
    end
    redirect_to( :action => 'list', :quiz_id => @quiz.id )
  end
end
