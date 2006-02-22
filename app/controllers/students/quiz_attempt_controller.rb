class Students::QuizAttemptController < Students::BaseController
  verify :method => :get, :only => %w( list )
  verify :method => :post, :only => %w( start )

  def list
    conditions = ['quizzes.id NOT IN (SELECT quiz_id FROM quiz_attempts WHERE quiz_attempts.user_id = ?) AND computers.ip_address = ?' ,
                  current_user.id,
		  request.remote_ip ]
    @quizzes = Quiz.find( :all,
                          :select => 'DISTINCT quizzes.*',
                          :joins =>
                            'LEFT OUTER JOIN subjects ON quizzes.subject_id = subjects.id ' +
                            'LEFT OUTER JOIN quizzes_rooms ON quizzes_rooms.quiz_id = quizzes.id ' +
                            'LEFT OUTER JOIN computers ON computers.room_id = quizzes_rooms.room_id ',
                          :conditions => conditions,
                          :order => 'subjects.name, quizzes.name')
  end

  def show_question
    @quiz = Quiz.find(params[:id])
    if ! @quiz.address_active?(request.remote_ip)
      flash[:alert] = 'Quiz not active for this Computer.'
      redirect_to(:action => 'list')
    elsif @quiz.user_completed?(current_user.id)
      flash[:alert] = 'User already completed Quiz.'
      redirect_to(:action => 'list')
    else
      @quiz_attempt = @quiz.quiz_attempt_for_user(current_user.id)
      if @quiz_attempt.time_up?(Time.now)
        flash[:alert] = 'Sorry, your time is up.'
        @quiz_attempt.complete
      else
        @quiz_response = @quiz_attempt.next_response
        if @quiz_response.nil?
          @quiz_attempt.complete
	end
        if request.post?
	  if @quiz_response.question.question_type == Question::MultiOptionType
            for answer in params[:answers]
              @quiz_response.answers << Answer.find(answer)
            end if params[:answers]
	  elsif @quiz_response.question.question_type == Question::SingleOptionType
	    if params[:answers].nil?
	      flash[:alert] = 'Must select an answer'
	      redirect_to( :action => 'show_question', :id => @quiz )
	      return
	    else
	      @quiz_response.answers << Answer.find(params[:answers])
	    end
	  elsif @quiz_response.question.question_type == Question::NumberType
	    number = params[:quiz_response][:input]
	    if  Regexp.new(/^\d+$/) =~ number 
	      @quiz_response.update_attributes( :input => params[:quiz_response][:input] )
            else
	      flash[:alert] = 'Must enter a number'
	      redirect_to( :action => 'show_question', :id => @quiz )
	      return
	    end
	  else
	    @quiz_response.update_attributes( :input => params[:quiz_response][:input] )
	  end
  	  @quiz_response.update_attributes(:completed => true)
          redirect_to(:action => 'show_question', :id => @quiz.id)
          return
        end
      end
      if @quiz_attempt.completed?
        redirect_to(:controller => 'results', :action => 'show', :id => @quiz_attempt.id)
      end
    end
  end
end
