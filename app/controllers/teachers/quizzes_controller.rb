class Teachers::QuizzesController < Teachers::BaseController

  def list
    @quiz_pages, @quizzes = paginate( :quizzes,
                                      :select => 'quizzes.*',
                                      :joins => ', educators',
                                      :conditions => ['quizzes.subject_id = educators.subject_id AND educators.user_id = ?', current_user.id],
                                      :per_page => 10 )
  end
  
  def disable_preview
    update_preview(false)
  end
  
  def enable_preview
    update_preview(true)
  end
  
  def show
    @quiz = Quiz.find(params[:id])
    @questions = Question.find(:all,
                             :conditions => ['quiz_items.quiz_id = ?', @quiz.id],
			     :joins => 'LEFT OUTER JOIN quiz_items ON quiz_items.question_id = questions.id ')
  end
  
  def change
    @quiz = Quiz.find(params[:id])
    if params[:quiz_item_ids] == nil
      flash[:alert] = 'must select something'
    else
      if params[:change] == '3'
        for quiz_item_id in params[:quiz_item_ids]
          QuizItem.delete(quiz_item_id)
        end
      else
        if params[:change] == '1'
          value = 'true'
        elsif params[:change] == '2'
          value = 'false'
        end
        for quiz_item_id in params[:quiz_item_ids]
          quiz_item = QuizItem.find(quiz_item_id)
          if ! quiz_item.update_attributes( :is_on_test => value )
            flash[:alert] = "not updated"
          end
        end
      end
    end
    redirect_to( :action => 'show', :id => @quiz.id )
  end
  
  def new
    @quiz = Quiz.new
    @subjects = Subject.find(:all)
    if request.post?
    @quiz = Quiz.new( params[:quiz] )
      if ! @quiz.save
        flash[:alert] = "Quiz could not be created"
      else
        flash[:notice] = 'Quiz was successfully created.'
        redirect_to( :action => 'show' , :id => @quiz.id )
      end
    end
  end
  
  def edit
    @quiz = Quiz.find(params[:id])
    @subjects = Subject.find(:all)
  end
  
  def update
    @quiz = Quiz.find(params[:id])
    if @quiz.update_attributes(params[:quiz])
      flash[:notice] = 'Quiz was successfully updated.'
      redirect_to( :action => 'show', :id => @quiz.id )
    else
      render( :action => 'edit' )
    end
  end
  
  def destroy
    @quiz = Quiz.find(params[:id])
    @subject = @quiz.subject_id
    @quiz.destroy
    redirect_to( :action => 'list', :subject_id => @subject )
  end
  
  def add_questions
    @quiz = Quiz.find(params[:id])
    if request.get?
      @questions = Question.find(:all,
        	         :conditions => ['id NOT IN (SELECT questions.id FROM questions RIGHT OUTER JOIN quiz_items ON quiz_items.question_id = questions.id WHERE quiz_items.quiz_id = ?)', @quiz.id] )
    else
      if params[:question_ids] == nil
        flash[:alert] = "Must select something"
      else
        for question in params[:question_ids]
          quiz_item = QuizItem.create( {:quiz_id => params[:id], :question_id => question } )
	  if ! quiz_item.valid?
	    flash[:alert] = "Some questions not added as they were already in quiz"
	  end
        end
      end
      redirect_to( :action => 'add_questions', :id => @quiz.id )
      return
    end
  end
  
private 
  def update_preview(value)
    @quiz = Quiz.find(params[:id])
    if ! @quiz.update_attributes( :prelim_enable => value )
      flash[:alert] = "Failed to update quiz."
    end
    redirect_to( :action => 'list', :id => @quiz.id )
  end
  
end
