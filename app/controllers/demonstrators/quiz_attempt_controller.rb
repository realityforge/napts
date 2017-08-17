class Demonstrators::QuizAttemptController < Demonstrators::BaseController
  verify :method => :post, :only => %w( reset )
  verify :method => :get, :only => %w( list )

  def list
    @quiz = current_subject.quizzes.find(params[:quiz_id])
    if params[:q]
      conditions = ['quiz_attempts.quiz_id = ? AND users.name LIKE ?', @quiz.id, "%#{params[:q]}%"]
    else
      conditions = ['quiz_attempts.quiz_id = ?', @quiz.id]
    end
    @quiz_attempt_pages, @quiz_attempts = paginate( :quiz_attempts,
                                                    :select => 'quiz_attempts.*',
                                                    :joins => 'LEFT OUTER JOIN users ON users.id = quiz_attempts.user_id',
                                                    :conditions => conditions,
                                                    :order_by => 'users.name',
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
