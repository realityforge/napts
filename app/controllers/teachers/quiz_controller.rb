class Teachers::QuizController < Teachers::BaseController
  def list
    @quiz_pages, @quizzes = paginate( :quizzes,
                                      :conditions => ['subject_id = ?', current_subject.id],
                                      :per_page => 10 )
  end
  
  def disable_preview
    update_preview(false)
  end
  
  def enable_preview
    update_preview(true)
  end
  
  def show
    @quiz = current_subject.quizzes.find(params[:id])
  end
  
  def list_quiz_items
    @quiz = current_subject.quizzes.find(params[:id])
    if params[:q]
      conditions = ['quiz_id = ? AND questions.content LIKE ?', 
                                 @quiz.id, "%#{params[:q]}%"]
    else
      conditions = ['quiz_id = ?', @quiz.id]
    end
    @quiz_item_pages, @quiz_items = 
        paginate( :quiz_items, 
	          :select => 'quiz_items.*',
	          :joins => 'LEFT OUTER JOIN questions ON questions.id = quiz_items.question_id',
	          :conditions => conditions,
		  :order => 'position',
		  :per_page => 10 )
  end
  
 def take_off_quiz
    @quiz = current_subject.quizzes.find(params[:id])
    @quiz_item = @quiz.quiz_items.find(params[:quiz_item_id])
    if ! @quiz_item.update_attributes( :is_on_test => false )
      flash[:alert] = 'Item not successfully taken off Quiz'
    end
    redirect_to( :action => 'list_quiz_items', :id => @quiz.id )
  end
  
  def put_on_quiz
    @quiz = current_subject.quizzes.find(params[:id])
    @quiz_item = @quiz.quiz_items.find(params[:quiz_item_id])
    if ! @quiz_item.update_attributes( :is_on_test => true )
      flash[:alert] = 'Item not successfully taken off Quiz'
    end
    redirect_to( :action => 'list_quiz_items', :id => @quiz.id )
  end
  
  def remove
    @quiz = current_subject.quizzes.find(params[:id])
    @quiz_item = @quiz.quiz_items.find(params[:quiz_item_id])
    QuizItem.delete(@quiz_item.id)
    redirect_to( :action => 'list_quiz_items', :id => @quiz.id )
  end
  
  def new
    @quiz = Quiz.new
    if request.post?
    @quiz = Quiz.new( params[:quiz] )
    @quiz.subject_id = current_subject.id
      if ! @quiz.save
        flash[:alert] = "Quiz could not be created"
      else
        flash[:notice] = 'Quiz was successfully created.'
        redirect_to( :action => 'show' , :id => @quiz.id )
      end
    end
  end
  
  def edit
    @quiz = current_subject.quizzes.find(params[:id])
    if request.post?
      if @quiz.update_attributes(params[:quiz])
        flash[:notice] = 'Quiz was successfully updated.'
        redirect_to( :action => 'show', :id => @quiz.id )
      end
    end
  end
  
  def destroy
    @quiz = current_subject.quizzes.find(params[:id])
    @quiz.destroy
    redirect_to( :action => 'list' )
  end
  
  def add_questions
    @quiz = current_subject.quizzes.find(params[:id])
    if request.get?
      if params[:q]
        conditions = ['id NOT IN (SELECT questions.id FROM questions RIGHT OUTER JOIN quiz_items ON quiz_items.question_id = questions.id WHERE quiz_items.quiz_id = ?) AND subject_group_id = ? AND questions.content LIKE ?',
	              @quiz.id, current_subject.subject_group_id, "%#{params[:q]}%" ]
      else
        conditions = ['id NOT IN (SELECT questions.id FROM questions RIGHT OUTER JOIN quiz_items ON quiz_items.question_id = questions.id WHERE quiz_items.quiz_id = ?) AND subject_group_id = ?',
	               @quiz.id, current_subject.subject_group_id ]
      end
      @question_pages, @questions = paginate( :questions, :conditions => conditions, :per_page => 10 )
    end
  end
  
  def add_to_quiz
    @quiz = Quiz.find(params[:id])
    @question = Question.find(params[:question_id])
    quiz_item = @quiz.quiz_items.create( {:quiz_id => @quiz.id, :question_id => @question.id} )
    redirect_to( :action => 'add_questions', :id => @quiz )
  end
  
  def move_up
    quiz_item = QuizItem.find(params[:id])
    quiz_item.move_higher
    redirect_to( :action => 'list_quiz_items', :id => quiz_item.quiz_id )
  end
  
  def move_down
    quiz_item = QuizItem.find(params[:id])
    quiz_item.move_lower
    redirect_to( :action => 'list_quiz_items', :id => quiz_item.quiz_id )
  end
  
  def move_first
    quiz_item = QuizItem.find(params[:id])
    quiz_item.move_to_top
    redirect_to( :action => 'list_quiz_items', :id => quiz_item.quiz_id )
  end
  
  def move_last
    quiz_item = QuizItem.find(params[:id])
    quiz_item.move_to_bottom
    redirect_to( :action => 'list_quiz_items', :id => quiz_item.quiz_id )
  end
  
private 
  def update_preview(value)
    @quiz = current_subject.quizzes.find(params[:id])
    if ! @quiz.update_attributes( :prelim_enable => value )
      flash[:alert] = "Failed to update quiz."
    end
    redirect_to( :action => 'list', :id => @quiz.id )
  end
  
end
