class QuizAttemptController < ApplicationController
  def intro
    @quiz = Quiz.find( :all, :conditions => ['id NOT IN (SELECT quiz_id FROM quiz_attempts WHERE quiz_attempts.user_id = ?) AND enable = ?' , @user.id, true ] )
  end
  
  def start_quiz
    @quiz = Quiz.find(params[:quiz_id])
    @quiz_attempt = QuizAttempt.create( :start_time => Time.now, 
                                        :quiz_id => @quiz.id, 
                                        :user_id => @user.id )

    for quiz_item in @quiz.quiz_items
      if quiz_item.is_on_test
        QuizResponse.create( :created_at => Time.now, 
                             :question_id => quiz_item.question.id,
	         	     :position => quiz_item.position,
			     :quiz_attempt_id => @quiz_attempt.id )
      end
    end
    redirect_to( :action => 'show',
                 :quiz_attempt_id => @quiz_attempt.id,
		 :quiz_response_position => 1 )
  end

  def show
    position = params[:quiz_response_position]
    attempt_id = params[:quiz_attempt_id]
    @quiz_response = 
        QuizResponse.find( :first, 
                           :conditions => [ 'position = ? AND quiz_attempt_id =?', 
	    	                            position, attempt_id ]
				   )
    if request.get? && !@quiz_response
      redirect_to( :action => 'end_quiz', :quiz_attempt_id => attempt_id )
    elsif request.post?
      if (( @quiz_response.question.question_type == 2 ) && ( params[:answers] == nil ))
	flash[:alert] = "Must select an answer"
      else
        if ! (params[:answers] == nil)
          for answer in params[:answers]
            @quiz_response.answers << Answer.find(answer)
          end
	end
	@quiz_response.update_attributes( :created_at => Time.now )
        redirect_to( :action => 'show',
	           :quiz_attempt_id => attempt_id,
		   :quiz_response_position => position.to_i + 1 )
      end
    end
  end
  
  def end_quiz
    @quiz_attempt =  QuizAttempt.find(params[:quiz_attempt_id])
    @quiz_attempt.update_attributes( :end_time => Time.now )
    redirect_to( :action => 'results', :quiz_attempt_id => @quiz_attempt.id )
  end
  
  def results
    @quiz_responses = 
      QuizResponse.find( :all, :conditions => ['quiz_attempt_id = ?', 
                                                params[:quiz_attempt_id]] )
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
end
