class Demonstrators::QuizzesController < Demonstrators::BaseController
  def restart
    @quizzes = current_subject.quizzes.find( :all, :conditions => ['enable = ? AND subject_id = ?', true, session[:subject_id]] )
    verify_demonstrator
    if request.post?
      if ! @user = User.find( :first, :conditions => ['username = ?', params[:username]] )
        flash[:alert] = "Username invalid"
      else
        if ! @quiz_attempt = QuizAttempt.find( :first, :conditions => ['user_id = ? AND quiz_id = ?',
	                                                               @user.id, params[:quiz][:name]] )
	  flash[:alert] = "Couldn't find quiz"
	else
	  @quiz_attempt.destroy
	  redirect_to( :action => 'enable_quiz' )
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
    verify_demonstrator
  end

  def disable
    update_quiz( false )
  end
  
  def enable
    update_quiz( true )
  end
  
private
  def update_quiz(value)
    @quiz = current_subject.quizzes.find(params[:id])
    verify_demonstrator
    if ! @quiz.update_attributes( :enable => value )
      flash[:alert] = "Failed to update quiz status."
    elsif @quiz.enable
      flash[:notice] = "Quiz #{@quiz.name} enabled at #{Time.now.strftime("%H:%M")}"
    end
    redirect_to( :action => 'enable_quiz', :id => @quiz.id )
  end
  
end
