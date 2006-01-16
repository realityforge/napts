class Students::QuizAttemptController < Students::BaseController
  def intro
    @quiz = Quiz.find( :all, :conditions => ['id NOT IN (SELECT quiz_id FROM quiz_attempts WHERE quiz_attempts.user_id = ?) AND enable = ?' , current_user.id, true ] )
  end
  
  def start_quiz
    @quiz = Quiz.find(params[:quiz_id])
    @quiz_attempt = QuizAttempt.create( :start_time => Time.now,
                                        :quiz_id => @quiz.id,
                                        :user_id => current_user.id )

    count = 1
    for quiz_item in @quiz.quiz_items
      if quiz_item.is_on_test
        QuizResponse.create( :created_at => Time.now,
                             :question_id => quiz_item.question.id,
	         	     :position => count,
			     :quiz_attempt_id => @quiz_attempt.id )
	count += count
      end
    end
    redirect_to( :action => 'show',
                 :quiz_attempt_id => @quiz_attempt.id,
		 :quiz_response_position => 1 )
  end
  
  def show
    position = params[:quiz_response_position]
    @quiz_attempt = QuizAttempt.find( params[:quiz_attempt_id] )
    @quiz_response = @quiz_attempt.get_response( position.to_i )
    if request.get? && ! @quiz_response
      redirect_to( :action => 'end_quiz', :quiz_attempt_id => @quiz_attempt.id, :out_of_time => false )
    elsif @quiz_attempt.time_up?
      redirect_to( :action => 'end_quiz', :quiz_attempt_id => @quiz_attempt.id, :out_of_time => true )
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
	             :quiz_attempt_id => @quiz_attempt.id,
	             :quiz_response_position => position.to_i + 1 )
      end
    end
  end
  
   def end_quiz
    if params[:out_of_time]
      flash[:alert] = "Sorry, your time is up"
    end
    @quiz_attempt =  QuizAttempt.find(params[:quiz_attempt_id])
    @quiz_attempt.update_attributes( :end_time => Time.now )
    redirect_to( :action => 'results', :quiz_attempt_id => @quiz_attempt.id )
  end

  def results
    @quiz_attempt = QuizAttempt.find(params[:quiz_attempt_id])
    @results = @quiz_attempt.incorrect_answers
  end
  
end