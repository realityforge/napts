class ResultsController < ApplicationController

  def index
    @quiz_attempt = QuizAttempt.find( :all, :conditions => ['user_id = ?', @user.id] )
  end

  def results
    quiz_attempt = QuizAttempt.find(params[:quiz_attempt])
    @quiz_responses = QuizResponse.find( :all, :conditions => ['quiz_attempt_id = ?',
                                                                quiz_attempt.id ] )
    @results = []
    for quiz_response in @quiz_responses
      responses = []
      correct = []
      for qr in quiz_response.answers
	responses << qr.answer_id.to_s
      end
      for q in quiz_response.question.answers
	correct << q.id.to_s if q.is_correct
      end
      if ! (responses == correct)
	@results << quiz_response.position.to_s
      end
    end
  end
  
  def calculate
    @results = []
    for quiz_response in @quiz_responses
      responses = []
      correct = []
      for qr in quiz_response.answers
	responses << qr.answer_id.to_s
      end
      for q in quiz_response.question.answers
	correct << q.id.to_s if q.is_correct
      end
      if ! (responses == correct)
	@results << quiz_response.position.to_s
      end
    end
    return @results
  end
  
  def total
    @quiz_attempts = QuizAttempt.find( :all, :conditions => ['user_id = ?', @user.id] )
    @quiz_name = []
    @numqns = []
    @numcorrect = []
    for attempt in @quiz_attempts
      @quiz_name << attempt.quiz.name
      @numqns << attempt.quiz_responses.length
      @results = 0
      for quiz_response in attempt.quiz_responses
        responses = []
        correct = []
        for qr in quiz_response.answers
	  responses << qr.answer_id.to_s
        end
        for q in quiz_response.question.answers
	  correct << q.id.to_s if q.is_correct
        end
        if ! (responses == correct)
	  @results = @results + 1
        end
      end
      
      @numcorrect << @results
    end
  end
end
