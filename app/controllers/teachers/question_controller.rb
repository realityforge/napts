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
      @question.answers = [Answer.new,Answer.new,Answer.new,Answer.new]
    elsif request.post?
      @question = Question.new(params[:question])
      @question.subject_group_id = current_subject.subject_group_id
      @question.corrected_at = Time.now
      is_valid = @question.valid?
      for answer_id in params[:answer].keys
        data = params[:answer][answer_id].dup
        answer = Answer.new(data)
	@question.answers << answer 
	if ! answer.valid?
	  is_valid = false
	end
      end
      if is_valid && @question.save
        @question.answers.each {|answer| answer.save}
      	flash[:notice] = 'Question was successfully created.'
	redirect_to( :action => 'show', :id => @question )
	return
      end
    end
    i = 1 
    for answer in @question.answers
        answer.id = i
	i = i + 1
    end
    @answers = @question.answers
  end  
  
  def edit
    @question = find_question(params[:id])
    if request.get?
      @answers = @question.answers
    elsif request.post?
      @answers = []
      if params[:answer]
        for id in params[:answer].keys
	  if ! id.index('new')
            answer = @question.answers.detect { |x| x.id.to_s == id.to_s }
	    if answer.nil?
	      flash[:alert] = "Update not successful"
	    else
	      answer.attributes = params[:answer][id]
	      @answers << answer
	    end
          else
	    answer = Answer.new( params[:answer][id] )
	    # This is just a temporary id used prior to saving to database 
	    answer.id = id.to_s
	    answer.question_id = @question.id
	    @answers << answer
	  end
        end
      end
      
      @question.attributes = params[:question]
      if params[:correct] 
        @question.corrected_at = Time.now
      end
      if params[:randomise]
        @question.randomise_answers
      end
      is_valid = true
      @answers.each do |x| 
      	is_valid = x.valid? && is_valid
      end
      is_valid &&= @question.valid?
      return unless is_valid && ! flash[:alert]
      
      Answer.transaction do
        for answer in @question.answers
	  if params[:answer] && ! params[:answer][answer.id.to_s]
	    @question.answers.delete(answer)
	  end
        end
	@question.save!
	@answers.each {|x| x.save!}
	flash[:notice] = 'Question was successfully updated.'
        redirect_to( :action => 'show', :id => @question )
        return
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
