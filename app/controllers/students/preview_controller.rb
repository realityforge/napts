class Students::PreviewController < Students::BaseController
  verify :method => :get, :only => %w( show list show_question resource )

  def list
    @subject = Subject.find(params[:subject_id])
    @quizzes = @subject.quizzes.find( :all, :conditions => ['preview_enabled = ?', true] )
  end

  def show
    @quiz = Quiz.find(params[:id], :conditions => ['preview_enabled = ?', true], :include => 'subject')
  end

  def show_question
    @quiz = Quiz.find(params[:id], :conditions => ['preview_enabled = ?', true])
    @quiz_item = QuizItem.find(:first,
                               :conditions => ['quiz_id = ? AND position = ?', @quiz.id, params[:position] ] )
    raise ActiveRecord::RecordNotFound, "Couldn't find QuizItem with preview_enabled = true AND quiz_id = #{params[:id]} AND position = #{params[:position]}" unless @quiz_item
    @resource_base = {:action => 'resource', :id => params[:id], :position => params[:position]}
  end

  def resource
    resource = Resource.find(:first,
                             :select => 'resources.*',
                             :conditions => ['quizzes.preview_enabled = ? AND quizzes.id = ? AND quiz_items.position = ? AND resources.name = ?',
                               true, params[:id], params[:position], params[:name] ],
                             :joins =>
                               'LEFT OUTER JOIN questions_resources ON resources.id = questions_resources.resource_id ' +
                               'LEFT OUTER JOIN questions ON questions_resources.question_id = questions.id ' +
                               'LEFT OUTER JOIN quiz_items ON questions.id = quiz_items.question_id ' +
                               'LEFT OUTER JOIN quizzes ON quiz_items.quiz_id = quizzes.id'
                             )
    raise ActiveRecord::RecordNotFound, "Couldn't find Resource named #{params[:name]} for Quiz with preview_enabled = true AND quiz_id = #{params[:id]} AND position = #{params[:position]}" unless resource

    disposition = (params[:disposition] == 'download') ? 'download' : 'inline'

    send_data(resource.resource_data.data,
              :filename => resource.name,
	      :type => resource.content_type,
	      :disposition => disposition )
  end
end
