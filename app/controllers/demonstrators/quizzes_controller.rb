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
  end
  
#  def enable
#    @quiz = Quiz.find(params[:id])
#    if @quiz.enable
#      if ! @quiz.update_attributes( :enable => false )
#        flash[:alert] = "Test could not be disabled"
#      end
#    else
#      if ! @quiz.update_attributes( :enable => true )
#        flash[:alert] = "Test could not be enabled"
#      else
#        flash[:notice] = "Test #{@quiz.name} enabled at #{Time.now.strftime("%H:%M")}"
#      end
#    end
#    redirect_to( :action => 'enable_quiz', :id => @quiz.id )
#  end
#  
  def disable
    update_quiz( false )
  end
  
  def enable
    update_quiz( true )
  end
  
private
  def update_quiz(value)
    @quiz = Quiz.find(params[:id])
    if ! @quiz.update_attributes( :enable => value )
      flash[:alert] = "Failed to update quiz status."
    end
    redirect_to( :action => 'enable_quiz', :id => @quiz.id )
  end
  
end
