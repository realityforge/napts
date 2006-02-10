class Teachers::QuizController < Teachers::BaseController
  verify :method => :get, :only => %w( list list_questions show )
  verify :method => :post, :only => %w( add_item toggle_preview_status destroy )

  def list
    if params[:q]
      conditions = ['subject_id = ? AND name LIKE ?', current_subject.id, "%#{params[:q]}%" ]
    else
      conditions = ['subject_id = ?', current_subject.id]
    end
    @quiz_pages, @quizzes = paginate(:quizzes,
                                     :conditions => ['subject_id = ?', current_subject.id],
                                     :per_page => 10 )
  end

  def toggle_preview_status
    quiz = current_subject.quizzes.find(params[:id])
    quiz.update_attribute(:prelim_enable,(params[:preview_status] == 'true'))
    redirect_to(:action => 'list', :q => params[:q], :page => params[:page])
  end
  
  def show
    @quiz = current_subject.quizzes.find(params[:id])
  end
  
  def new
    @quiz = Quiz.new(params[:quiz])
    if request.get?
      @quiz.randomise = true
    elsif request.post?
      @quiz.subject_id = current_subject.id
      if @quiz.save
        flash[:notice] = 'Quiz was successfully created.'
        redirect_to(:action => 'show' , :id => @quiz.id)
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
  
  def list_questions
    @quiz = current_subject.quizzes.find(params[:id])
    if params[:q]
      conditions = ['id NOT IN (SELECT questions.id FROM questions RIGHT OUTER JOIN quiz_items ON quiz_items.question_id = questions.id WHERE quiz_items.quiz_id = ?) AND subject_group_id = ? AND questions.content LIKE ?',
        @quiz.id, current_subject.subject_group_id, "%#{params[:q]}%" ]
    else
      conditions = ['id NOT IN (SELECT questions.id FROM questions RIGHT OUTER JOIN quiz_items ON quiz_items.question_id = questions.id WHERE quiz_items.quiz_id = ?) AND subject_group_id = ?',
        @quiz.id, current_subject.subject_group_id ]
    end
    @question_pages, @questions = paginate( :questions, :conditions => conditions, :per_page => 10 )
  end
  
  def add_item
    quiz = current_subject.quizzes.find(params[:id])
    question = Question.find(params[:question_id], :conditions => ['subject_group_id = ?', current_subject.subject_group_id])
    quiz_item = quiz.quiz_items.create!(:question_id => question.id, :is_on_test => true)
    redirect_to(:action => 'list_questions', :id => quiz, :q => params[:q], :page => params[:page])
  end
  
  def destroy
    current_subject.quizzes.find(params[:id]).destroy
    flash[:notice] = 'Quiz was successfully deleted.'
    redirect_to(:action => 'list', :q => params[:q], :page => params[:page])
  end
end
