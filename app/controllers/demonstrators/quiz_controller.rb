class Demonstrators::QuizController < Demonstrators::BaseController
  verify :method => :post, :only => %w( disable enable )
  verify :method => :get, :only => %w( list show )

  def list
    @quizzes = current_subject.quizzes.find(:all, :order => 'created_at')
  end

  def show
    @quiz = current_subject.quizzes.find(params[:id], :include => 'subject')
    @rooms = Room.find(:all)
  end

  def disable
#    update_quiz(false)
  end
  
  def enable
#    update_quiz(true)
  end
  
#private
#  def update_quiz(value)
#    quiz = current_subject.quizzes.find(params[:id])
#    quiz.enable = value
#    quiz.save!
#    if quiz.enable?
#      flash[:notice] = "Quiz #{quiz.name} enabled at #{Time.now.strftime("%H:%M")}"
#    end
#    redirect_to(:action => 'show', :id => quiz.id)
#  end
end
