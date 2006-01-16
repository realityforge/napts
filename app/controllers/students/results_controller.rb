class Students::ResultsController < Students::BaseController
  def results
    @quiz_attempt = QuizAttempt.find(params[:quiz_attempt])
  end

  def statistics
    @quiz_name = []
    @score = []
    @subject = []
    @date = []
    for attempt in current_user.quiz_attempts
      @quiz_name << attempt.quiz.name
      @numqns = attempt.quiz_responses.length
      @score << @numqns - attempt.incorrect_answers.length
      @subject << attempt.quiz.subject.code
      @date << attempt.start_time
    end
  end
end
