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
  
  def restart
    if request.post?
      @other_user = User.find( :first, :conditions => ['username = ? ', params[:username]] )
      @quiz_attempt = QuizAttempt.find( :first,
                                        :conditions => ['user_id = ? AND end_time IS NULL', @other_user.id ] )
      @quiz_attempt.destroy
      redirect_to( :controller => 'welcome', :action => 'index' )
    end
  end
  
  def show
    position = params[:quiz_response_position]
    @quiz_attempt = QuizAttempt.find( params[:quiz_attempt_id] )
    @quiz_response = QuizResponse.find( :first, 
                                        :conditions => [ 'position = ? AND quiz_attempt_id =?', 
	    	                            position, @quiz_attempt.id ]
				   )
    if request.get? && !@quiz_response
      redirect_to( :action => 'end_quiz', :quiz_attempt_id => @quiz_attempt.id, :out_of_time => false )
    elsif request.post?
      if (( @quiz_response.question.question_type == 2 ) && ( params[:answers] == nil ))
	flash[:alert] = "Must select an answer"
      else
        if ! ( @quiz_attempt.time_up? )
          if ! (params[:answers] == nil)
            for answer in params[:answers]
              @quiz_response.answers << Answer.find(answer)
            end
	  end
	  @quiz_response.update_attributes( :created_at => Time.now )
          redirect_to( :action => 'show',
	               :quiz_attempt_id => @quiz_attempt.id,
		       :quiz_response_position => position.to_i + 1 )
	else
	  redirect_to( :action => 'end_quiz', :quiz_attempt_id => @quiz_attempt.id, :out_of_time => true )
	end
      end
    end
  end
  
  def end_quiz
    if :out_of_time
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
