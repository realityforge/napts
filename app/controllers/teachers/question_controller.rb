class Teachers::QuestionController < Teachers::BaseController
  verify :method => :get, :only => %w( list show )
  verify :method => :post, :only => %w( add_resource remove_resource destroy )

  def list
    if params[:q]
      conditions = ['subject_group_id = ? AND content LIKE ?',
                     current_subject.subject_group_id, "%#{params[:q]}%"]
    else
      conditions = ['subject_group_id = ?', current_subject.subject_group_id]
    end
    @question_pages, @questions = paginate(:question,
                                           :conditions => conditions,
                                           :per_page => 10)
  end

  def gen_answer
    render(:partial => 'answer', :locals => {:key => Time.now.to_i, :choice => {}}, :layout => false)
  end

  def show
    @question = current_subject.subject_group.questions.find(params[:id])
  end

  def new
    @question = Question.new(params[:question])
    if request.get?
      @question.randomise = true
      @question.text_format = TextFormatter::RedClothFormat
      @question.question_type = Question::MultiOptionType
      @question.answers = [Answer.new,Answer.new,Answer.new,Answer.new]
    elsif request.post?
      @question.subject_group_id = current_subject.subject_group_id
      @question.corrected_at = Time.now
      @question.choices = params[:choice]
      if @question.save
	flash[:notice] = 'Question was successfully created.'
	redirect_to(:action => 'show', :id => @question)
      end
    end
  end

  def edit
    @question = find_question(params[:id])
    if request.post?
      if params[:correct]
        @question.corrected_at = Time.now
	@quiz_attempts = QuizAttempt.find( :all,
	                                   :select => 'quiz_attempts.*',
	                                   :conditions =>  ['quiz_responses.question_id = ? AND quiz_attempts.end_time IS NOT NULL', @question.id],
	                                   :joins => 'LEFT JOIN quiz_responses ON quiz_responses.quiz_attempt_id = quiz_attempts.id',
					   :readonly => false)

	for quiz_attempt in @quiz_attempts
	  quiz_attempt.update_attributes(:score => nil)
	end
      end
      @question.attributes = params[:question]
      @question.choices = params[:choice]
      if @question.save
        flash[:notice] = 'Question was successfully updated.'
        redirect_to(:action => 'show', :id => @question)
      end
    end
  end

  def list_resources
    @question = find_question(params[:id])
    if params[:q]
      conditions = ['subject_group_id = ? AND name LIKE ? AND id NOT IN (SELECT resource_id FROM questions_resources WHERE question_id = ?)',
        current_subject.subject_group_id, "%#{params[:q]}%", @question.id]
    else
      conditions = ['subject_group_id = ? AND id NOT IN (SELECT resource_id FROM questions_resources WHERE question_id = ?)',
        current_subject.subject_group_id, @question.id]
    end
    @resource_pages, @resources = paginate(:resource,
                                           :conditions => conditions,
                                           :per_page => 10)
  end

  def add_resource
    question = find_question(params[:id])
    question.resources << find_resource(params[:resource_id])
    flash[:notice] = 'Resource was successfully added to question.'
    redirect_to(:action => 'list_resources', :id => question.id)
  end

  def remove_resource
    resource = find_resource(params[:resource_id])
    question = find_question(params[:id])
    question.resources.delete(resource)
    flash[:notice] = 'Resource was successfully removed from question.'
    redirect_to(:action => 'show', :id => question.id)
  end

  def destroy
    question = find_question(params[:id])
    if question.quiz_items.length > 0
      flash[:alert] = 'Question in quiz so cannot be deleted.'
    else
      current_subject.subject_group.questions.find(params[:id]).destroy
      flash[:notice] = 'Question was successfully deleted.'
    end
    redirect_to(:action => 'list', :q => params[:q], :page => params[:page])
  end

  def show_question
    @question = find_question(params[:id])
    @resource_base = {:action => 'resource', :id => params[:id], :position => params[:position]}
  end

  def resource
    resource = Resource.find(:first,
                             :select => 'resources.*',
                             :conditions => ['questions_resources.question_id = ? AND resources.name = ? AND resources.subject_group_id = ?',
                               params[:id], params[:name], current_subject.subject_group_id ],
                             :joins => 'LEFT OUTER JOIN questions_resources ON resources.id = questions_resources.resource_id'
                             )
    raise ActiveRecord::RecordNotFound, "Couldn't find Resource named #{params[:name]} for question = #{params[:id]}" unless resource
    disposition = (params[:disposition] == 'download') ? 'download' : 'inline'
    send_data(resource.resource_data.data,
              :filename => resource.name,
	      :type => resource.content_type,
	      :disposition => disposition )
  end

private
  def find_question(question_id)
    Question.find(question_id, :conditions => ['subject_group_id = ?', current_subject.subject_group_id])
  end

  def find_resource(resource_id)
    Resource.find(resource_id, :conditions => ['subject_group_id = ?', current_subject.subject_group_id])
  end
end
