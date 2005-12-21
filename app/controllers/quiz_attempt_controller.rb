class QuizAttemptController < ApplicationController
  def intro
    @quiz = Quiz.find(:all)
  end
  
  def start_quiz
    @quiz = Quiz.find(params[:quiz_id])
    @quiz_attempt = QuizAttempt.create( :start_time => Time.now, 
                                        :quiz_id => @quiz.id, 
                                        :user_id => @user.id )

    for quiz_item in @quiz.quiz_items
      QuizResponse.create( :created_at => Time.now, 
                           :question_id => quiz_item.question.id,
			   :position => quiz_item.position,
			   :quiz_attempt_id => @quiz_attempt.id )
    end
    redirect_to( :action => 'show',
                 :quiz_attempt_id => @quiz_attempt.id,
		 :quiz_response_position => 1 )
  end
  
  def show
    position = params[:quiz_response_position]
    attempt_id = params[:quiz_attempt_id]
    @quiz_response = QuizResponse.find( :first, 
                                   :conditions => [ 'position = ? AND quiz_attempt_id =?', 
				                    position, 
				                    attempt_id ] 
  				 )
    if request.get? && !@quiz_response
      redirect_to( :action => 'results', :quiz_attempt_id => attempt_id )
    elsif request.post?
      for answer in params[:answers]
        @quiz_response.answers << Answer.find(answer)
      end
      redirect_to( :action => 'show',
	           :quiz_attempt_id => attempt_id,
		   :quiz_response_position => position.to_i + 1 )
    end
  end
  
  def results
    
    @quiz_response = QuizResponse.find( :all, :conditions => ['quiz_attempt_id = ?', :quiz_attempt_id] )
    
  end
end
