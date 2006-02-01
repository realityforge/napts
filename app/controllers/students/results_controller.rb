class Students::ResultsController < Students::BaseController
  def show
    @quiz_attempt = current_user.quiz_attempts.find(params[:id])
  end

  def list
    @quiz_attempts = QuizAttempt.find(:all,
                                      :select => 'quiz_attempts.*',
                                      :joins => 'LEFT OUTER JOIN quizzes ON quizzes.id = quiz_attempts.quiz_id',
                                      :conditions => ['subject_id = ? AND user_id = ?', params[:id], current_user.id],
				      :order => 'start_time DESC')
  end
end
