class Demonstrators::QuizzesController < Demonstrators::BaseController
  
  def restart
    if request.post?
      @other_user = User.find( :first, :conditions => ['username = ? ', params[:username]] )
      @quiz_attempt = QuizAttempt.find( :first,
                                        :conditions => ['user_id = ? AND end_time IS NULL', @other_user.id ] )
      @quiz_attempt.destroy
      redirect_to( :action => 'index' )
    end
  end
  
  def enable_quiz
    @quiz_pages, @quizzes = paginate( :quizzes,
                                      :select => 'quizzes.*',
				      :joins => ', demonstrators',
				      :conditions => ['quizzes.subject_id = demonstrators.subject_id AND demonstrators.user_id = ?', current_user.id],
				      :per_page => 10 )
    verify_access
  end

  def disable
    update_quiz( false )
  end
  
  def enable
    update_quiz( true )
  end
  
protected
  def current_subject_id
    @quiz ? @quiz.subject_id : nil
  end
  
private
  def update_quiz(value)
    @quiz = Quiz.find(params[:id])
    verify_access
    if ! @quiz.update_attributes( :enable => value )
      flash[:alert] = "Failed to update quiz status."
    end
    redirect_to( :action => 'enable_quiz', :id => @quiz.id )
  end
  
end
