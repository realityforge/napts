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
          for answer in params[:answers]
            @quiz_response.answers << Answer.find(answer)
          end if params[:answers]
  	  @quiz_response.update_attributes(:created_at => Time.now, :completed => true)
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
