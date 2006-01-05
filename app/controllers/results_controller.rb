class ResultsController < ApplicationController

  def results
    @quiz_attempt = QuizAttempt.find(params[:quiz_attempt])
  end

  def statistics
    @quiz_name = []
    @score = []
    @subject = []
    for attempt in @user.quiz_attempts
      @quiz_name << attempt.quiz.name
      @numqns = attempt.quiz_responses.length
      @score << @numqns - attempt.score.length
      @subject << attempt.quiz.subject.code
    end
  end

end
