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
  
  def show
    @question = current_subject.subject_group.questions.find(params[:id])
  end
  
  def new
    @question = Question.new(params[:question])
    if request.get?
      @question.randomise = true
      @question.text_format = 1
      @question.question_type = 1
      @question.answers = [Answer.new,Answer.new,Answer.new,Answer.new]
      @number_answer = Answer.new
      @text_answer = Answer.new
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
      @question.corrected_at = Time.now if params[:correct] 
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

private
  def find_question(question_id)
    Question.find(question_id, :conditions => ['subject_group_id = ?', current_subject.subject_group_id])
  end

  def find_resource(resource_id)
    Resource.find(resource_id, :conditions => ['subject_group_id = ?', current_subject.subject_group_id])
  end
end
