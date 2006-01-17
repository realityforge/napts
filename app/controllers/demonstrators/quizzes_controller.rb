class Demonstrators::QuizzesController < Demonstrators::BaseController
  
#  def restart
#    @quizzes = Quiz.find( :all, :conditions => ['enable = ?', true] )
#    if request.post?
#      if ! @other_user = User.find( :first, :conditions => ['username = ? ', params[:username]] )
#        flash[:alert] = "Username not valid"
#      else
#        if ! @quiz_attempt = QuizAttempt.find( :first,
#                                               :conditions => ['user_id = ? AND end_time IS NULL',
#					                      @other_user.id ] )
#          flash[:alert] = "Cannot find an unfinished quiz to restart"
#	else
#          @quiz_attempt.destroy
#	  redirect_to( :action => 'index' )
#	end
#      end
#    end
#  end
  
  def restart
    @quizzes = Quiz.find( :all, :conditions => ['enable = ? AND subject_id = ?', true, session[:subject_id]] )
    if request.post?
      if ! @user = User.find( :first, :conditions => ['username = ?', params[:username]] )
        flash[:alert] = "Username invalid"
      else
        if ! @quiz_attempt = QuizAttempt.find( :first, :conditions => ['user_id = ? AND quiz_id = ?',
	                                                               @user.id, params[:quiz][:name]] )
	  flash[:alert] = "Couldn't find quiz"
	else
	  @quiz_attempt.destroy
	  redirect_to( :controller => 'welcome', :action => 'index' )
	end
      end
    end
  end
  
  def enable_quiz
    @quiz_pages, @quizzes = paginate( :quizzes,
                                      :select => 'quizzes.*',
				      :joins => ', demonstrators',
				      :conditions => ['quizzes.subject_id = demonstrators.subject_id AND demonstrators.user_id = ?', current_user.id],
				      :per_page => 10 )
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
    elsif @quiz.enable
      flash[:notice] = "Quiz #{@quiz.name} enabled at #{Time.now.strftime("%H:%M")}"
    end
    redirect_to( :action => 'enable_quiz', :id => @quiz.id )
  end
  
end
