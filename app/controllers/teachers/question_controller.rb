class Teachers::QuestionController < Teachers::BaseController
  def list
    @question_pages, @questions = paginate( :question, 
                                            :conditions => ['subject_group_id = ?', current_subject.subject_group.id],
                                            :per_page => 10 )
  end
  
  def show
    @question = current_subject.subject_group.questions.find(params[:id])
  end
  
  def new
    if request.get?
      @question = Question.new
      @question.answers = [Answer.new,Answer.new,Answer.new,Answer.new]
    elsif request.post?
      @question = Question.new(params[:question])
      @question.subject_group_id = current_subject.subject_group_id
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
    @question = current_subject.subject_group.questions.find(params[:id])
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
  
  def destroy
    @question = current_subject.subject_group.questions.find(params[:id])
    if @question.quiz_items.length > 0
      flash[:alert] = 'Question in quiz so cannot be destroyed'
    else
      current_subject.subject_group.questions.find(params[:id]).destroy
    end
    redirect_to( :action => 'list' )
  end
  
end
