class Demonstrators::QuizzesController < Demonstrators::BaseController
  def restart
    if request.post?
      @quiz = current_subject.quizzes.find(params[:quiz_id])
      
      if ! @user = User.find( :first, :conditions => ['username = ?', params[:username]] )
        flash[:alert] = "Username invalid"
      else
        @quiz_attempt = @quiz.quiz_attempts.find(:first, :conditions => ['user_id = ?', @user.id])
        if ! @quiz_attempt
	  flash[:alert] = 'User had not attempted quiz'
	else
	  @quiz_attempt.destroy
	  redirect_to( :action => 'restart' )
          return
	end
      end
    end
    @quizzes = current_subject.quizzes.find( :all, :conditions => ['enable = ?', true] )
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
  
private
  def update_quiz(value)
    @quiz = current_subject.quizzes.find(params[:id])
    if ! @quiz.update_attributes( :enable => value )
      flash[:alert] = "Failed to update quiz status."
    elsif @quiz.enable
      flash[:notice] = "Quiz #{@quiz.name} enabled at #{Time.now.strftime("%H:%M")}"
    end
    redirect_to( :action => 'enable_quiz', :id => @quiz.id )
  end
  
end
