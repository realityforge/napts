class Students::ResultsController < Students::BaseController
  def show
    @quiz_attempt = current_user.quiz_attempts.find(params[:id])
  end

  def list
    @quiz_attempts = QuizAttempt.find(:all,
                                      :select => 'quiz_attempts.*',
                                      :joins => 'LEFT OUTER JOIN quizzes ON quizzes.id = quiz_attempts.quiz_id',
                                      :conditions => ['subject_id = ? AND user_id = ? AND end_time IS NOT NULL', params[:id], current_user.id],
				      :order => 'created_at DESC',
				      :readonly => false)
  end
  
  #make sure it is the right user,  ~
  #make sure publish_results is set to true  ~
  #make sure they got that question wrong 
  def show_question
    @quiz_attempt = current_user.quiz_attempts.find(params[:id])
    if @quiz_attempt.quiz.publish_results?
      @quiz_response = @quiz_attempt.quiz_responses.find( :first, :conditions => ['quiz_attempt_id = ? AND position = ?', @quiz_attempt.id, params[:position]])
      if @quiz_response.correct?
        flash[:alert] = 'This question was answered correctly'
      end
    else
      flash[:alert] = 'Results are not currently enabled'
      redirect_to( :action => 'show', :id => @quiz_attempt )
    end
  end
end
