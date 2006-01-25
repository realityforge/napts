class Students::PreviewController < Students::BaseController
  verify :method => :get, :only => %w( show list show_question )
  def list
    @subject = Subject.find(params[:subject_id])
    @quizzes = Quiz.find( :all, :conditions => ['prelim_enable = ? AND subject_id = ?', true, @subject.id] )
  end

  def show
    @quiz = Quiz.find(params[:id], :include => 'subject')
  end

  def show_question
    @quiz_item = QuizItem.find(:first,
                               :conditions => ['quiz_id = ? AND position = ?', params[:id], params[:position] ] )
    raise ActiveRecord::RecordNotFound, "Couldn't find QuizItem with quiz_id = #{params[:id]} AND position = #{params[:position]}" unless @quiz_item
  end
end
