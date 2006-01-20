class Teachers::QuizzesController < Teachers::BaseController
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
  
  def change
    @quiz = current_subject.quizzes.find(params[:id])
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
          quiz_item = @quiz.quiz_items.find(quiz_item_id)
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
      @questions = Question.find(:all,
        	                :conditions => ['id NOT IN (SELECT questions.id FROM questions RIGHT OUTER JOIN quiz_items ON quiz_items.question_id = questions.id WHERE quiz_items.quiz_id = ?) AND subject_group_id = ?',
				@quiz.id, current_subject.subject_group_id ] )
    else
      if params[:question_ids].nil?
        flash[:alert] = "Must select something"
      else
        for question in params[:question_ids]
          quiz_item = @quiz.quiz_items.create( {:quiz_id => params[:id],
	                                        :question_id => question } )
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
    @quiz = current_subject.quizzes.find(params[:id])
    if ! @quiz.update_attributes( :prelim_enable => value )
      flash[:alert] = "Failed to update quiz."
    end
    redirect_to( :action => 'list', :id => @quiz.id )
  end
  
end
