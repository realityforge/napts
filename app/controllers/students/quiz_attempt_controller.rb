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
    if ! @quiz.address_enabled?(request.remote_ip)
      flash[:alert] = 'Quiz not active for this Computer.'
      redirect_to(:action => 'list')
    elsif @quiz.user_completed?(current_user.id)
      flash[:alert] = 'User already completed Quiz.'
      redirect_to(:action => 'list')
    else
      @quiz_attempt = @quiz.quiz_attempt_for_user(current_user.id)

      if @quiz_attempt.time_up?
        flash[:alert] = 'Sorry, your time is up.'
        @quiz_attempt.complete
      else
        @quiz_response = @quiz_attempt.next_response
        if @quiz_response.nil?
          @quiz_attempt.complete
        elsif request.post?
          # TODO: Save answer and add flip response flag here
          redirect_to( :action => 'show_question', :id => @quiz.id )
          return
        end
      end

      if @quiz_attempt.complete?
        redirect_to( :controller => 'results', :action => 'show', :id => @quiz_attempt.id )
      end
    end
  end

  def start
    @quiz = Quiz.find(params[:id])
    if ! @quiz.address_enabled?(request.remote_ip)
      flash[:alert] = 'Quiz not active for this Computer.'
      redirect_to(:action => 'list')
      # TODO: Check user has not completed or started quiz
    else
      @quiz_attempt = QuizAttempt.create( :start_time => Time.now,
                                          :quiz_id => @quiz.id,
                                          :user_id => current_user.id )
      redirect_to( :action => 'show',
                   :quiz_attempt_id => @quiz_attempt.id,
	           :quiz_response_position => 1 )
    end
  end
  
  def show
    position = params[:quiz_response_position]
    @quiz_attempt = QuizAttempt.find( params[:quiz_attempt_id] )
    @quiz_response = @quiz_attempt.get_response( position.to_i )
    if @quiz_attempt.quiz.address_enabled?(request.remote_ip)
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
    else
      flash[:alert] = "Quiz not currently enabled on this computer"
      redirect_to( :action => 'intro' )
    end
  end
  
   def end_quiz
    if params[:out_of_time]
      flash[:alert] = "Sorry, your time is up"
    end
    @quiz_attempt =  QuizAttempt.find(params[:quiz_attempt_id])
    @quiz_attempt.update_attributes( :end_time => Time.now )
    redirect_to( :controller => 'results', :action => 'show', :id => @quiz_attempt.id )
  end

end
