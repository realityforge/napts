class Students::ResultsController < Students::BaseController
  def show
    @quiz_attempt = current_user.quiz_attempts.find(params[:id])
  end

  def list
    @subject = Subject.find(params[:subject_id])
    @quiz_attempts = QuizAttempt.find(:all,
                                      :select => 'quiz_attempts.*',
                                      :joins => 'LEFT OUTER JOIN quizzes ON quizzes.id = quiz_attempts.quiz_id',
                                      :conditions => ['subject_id = ? AND user_id = ? AND end_time IS NOT NULL', @subject.id, current_user.id],
				      :order => 'created_at DESC',
				      :readonly => false)

  end

  def show_question
    @quiz_attempt = current_user.quiz_attempts.find(params[:id])
    if @quiz_attempt.quiz.publish_results?
      @quiz_response = @quiz_attempt.quiz_responses.find(:first,
                                                         :conditions => ['quiz_attempt_id = ? AND position = ?', @quiz_attempt.id, params[:position]])
      @resource_base = {:action => 'resource', :id => @quiz_attempt.quiz_id, :position => @quiz_response.position}
      flash[:alert] = 'This question was answered correctly' if @quiz_response.correct?
    else
      flash[:alert] = 'Results are not currently enabled'
      redirect_to( :action => 'show', :id => @quiz_attempt )
    end
  end


  def resource
    resource = Resource.find(:first,
                             :select => 'resources.*',
                             :conditions => ['quizzes.publish_results = ? AND quizzes.id = ? AND quiz_attempts.end_time IS NOT NULL AND quiz_attempts.user_id = ? AND quiz_responses.position = ? AND resources.name = ?',
                               true, params[:id], current_user.id, params[:position], params[:name] ],
                             :joins =>
                               'LEFT OUTER JOIN questions_resources ON resources.id = questions_resources.resource_id ' +
                               'LEFT OUTER JOIN questions ON questions_resources.question_id = questions.id ' +
                               'LEFT OUTER JOIN quiz_responses ON questions.id = quiz_responses.question_id ' +
                               'LEFT OUTER JOIN quiz_attempts ON quiz_responses.quiz_attempt_id = quiz_attempts.id ' +
                               'LEFT OUTER JOIN quizzes ON quiz_attempts.quiz_id = quizzes.id'
                             )
    raise ActiveRecord::RecordNotFound, "Couldn't find Resource named #{params[:name]} for Quiz.id = #{params[:id]} AND position = #{params[:position]}" unless resource

    disposition = (params[:disposition] == 'download') ? 'download' : 'inline'

    send_data(resource.resource_data.data,
              :filename => resource.name,
	      :type => resource.content_type,
	      :disposition => disposition )
  end
end
