class Students::PreviewController < Students::BaseController
  verify :method => :get, :only => %w( show list show_question )
  def list
    @subject = Subject.find(params[:subject_id])
    @quizzes = @subject.quizzes.find( :all, :conditions => ['prelim_enable = ?', true] )
  end

  def show
    @quiz = Quiz.find(params[:id], :conditions => ['prelim_enable = ?', true], :include => 'subject')
  end

  def show_question
    @quiz = Quiz.find(params[:id], :conditions => ['prelim_enable = ?', true])
    @quiz_item = QuizItem.find(:first,
                               :conditions => ['quiz_id = ? AND position = ?', @quiz.id, params[:position] ] )
    raise ActiveRecord::RecordNotFound, "Couldn't find QuizItem with prelim_enable = true AND quiz_id = #{params[:id]} AND position = #{params[:position]}" unless @quiz_item
  end
end
