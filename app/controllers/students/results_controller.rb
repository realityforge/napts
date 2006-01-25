class Students::ResultsController < Students::BaseController
  def show
    @quiz_attempt = QuizAttempt.find(params[:quiz_attempt])
  end

  def list
    @quiz_attempts = QuizAttempt.find(:all,
                                      :select => 'quiz_attempts.*',
                                      :joins => 'LEFT OUTER JOIN quizzes ON quizzes.id = quiz_attempts.quiz_id',
                                      :conditions => ['subject_id = ? AND user_id = ?', params[:subject_id], current_user.id],
				      :order => 'start_time DESC')
    @quiz_name = []
    @score = []
    @date = []
    for attempt in @quiz_attempts
      @quiz_name << attempt.quiz.name
      @numqns = attempt.quiz_responses.length
      @score << @numqns - attempt.incorrect_answers.length
      @date << attempt.start_time
    end
  end
end
