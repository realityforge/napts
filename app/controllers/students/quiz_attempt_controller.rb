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
    logger.warn "show_question(#{@quiz.id})"
    if ! @quiz.address_active?(request.remote_ip)
      flash[:alert] = 'Quiz not active for this Computer.'
      redirect_to(:action => 'list')
    elsif @quiz.user_completed?(current_user.id)
      logger.warn "--- completed!"
      flash[:alert] = 'User already completed Quiz.'
      redirect_to(:action => 'list')
    else
      logger.warn "--- in progress"
      @quiz_attempt = @quiz.quiz_attempt_for_user(current_user.id, request.remote_ip)
      if @quiz_attempt.time_up?(Time.now)
        logger.warn "--- time up"
        flash[:alert] = 'Sorry, your time is up.'
        @quiz_attempt.complete
      else
        @quiz_response = @quiz_attempt.next_response
	logger.warn "--- response #{@quiz_response}"
        if @quiz_response.nil?
          @quiz_attempt.complete
        else
          @resource_base = {:action => 'resource', :id => params[:id], :position => @quiz_response.position}
	end
	
        if request.post?
          type = @quiz_response.question.question_type
          logger.warn "--- request.post? type #{type}"
          if type == Question::SingleOptionType && params[:answers].nil?
            flash[:alert] = 'Must select an answer'
            redirect_to( :action => 'show_question', :id => @quiz )
            return
          elsif type == Question::NumberType && ! (params[:quiz_response][:input] =~ /^\d+$/)
            flash[:alert] = 'Must enter a number'
            redirect_to( :action => 'show_question', :id => @quiz )
            return
          end

	  if type == Question::MultiOptionType || type == Question::SingleOptionType
            for answer in params[:answers]
	      logger.warn "--- loop"
              @quiz_response.answers << Answer.find(answer)
            end if params[:answers]
	  elsif @quiz_response.question.question_type == Question::NumberType
	    logger.warn "--- skip"
            @quiz_response.update_attributes( :input => params[:quiz_response][:input] )
	  end
  	  @quiz_response.update_attributes(:completed => true)
          redirect_to(:action => 'show_question', :id => @quiz.id)
          return
        end
      end
      logger.warn "--- @quiz_attempt.completed? = #{@quiz_attempt.completed?}"
      if @quiz_attempt.completed?
        redirect_to(:controller => 'results', :action => 'show', :id => @quiz_attempt.id)
      end
    end    
  end

  def resource
    resource = Resource.find(:first,
                             :select => 'resources.*',
                             :conditions => ['quiz_attempts.quiz_id = ? AND quiz_attempts.end_time IS NULL AND quiz_attempts.user_id = ? AND quiz_responses.position = ? AND resources.name = ?', 
                               params[:id], current_user.id, params[:position], params[:name] ],
                             :joins => 
                               'LEFT OUTER JOIN questions_resources ON resources.id = questions_resources.resource_id ' +
                               'LEFT OUTER JOIN questions ON questions_resources.question_id = questions.id ' +
                               'LEFT OUTER JOIN quiz_responses ON questions.id = quiz_responses.question_id ' +
                               'LEFT OUTER JOIN quiz_attempts ON quiz_responses.quiz_attempt_id = quiz_attempts.id'
                             )
    raise ActiveRecord::RecordNotFound, "Couldn't find Resource named #{params[:name]} for Quiz.id = #{params[:id]} AND position = #{params[:position]}" unless resource

    disposition = (params[:disposition] == 'download') ? 'download' : 'inline'
    
    send_data(resource.resource_data.data, 
              :filename => resource.name,
	      :type => resource.content_type,
	      :disposition => disposition )
  end
end
