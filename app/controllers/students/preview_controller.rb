class Students::PreviewController < Students::BaseController
  def list
    @subject = Subject.find(params[:subject_id])
    @quiz = Quiz.find( :all, :conditions => ['prelim_enable = ? AND subject_id = ?', true, @subject.id] )
  end
  
  def view_quiz
    @quiz = Quiz.find( params[:quiz_id] )
    position = params[:quiz_item_position]
    @quiz_item = QuizItem.find( :first,
                                :conditions => ['quiz_id = ? AND position = ?',
				                @quiz.id, position ] )
    if @quiz_item
      @question = @quiz_item.question
      if request.post?
        redirect_to( :action => 'view_quiz', 
                     :quiz_item_position => position.to_i + 1,
	       	     :quiz_id => @quiz.id )
      end
    else
      redirect_to(:action => 'list', :subject_id => @quiz.subject_id)
    end
  end
end
