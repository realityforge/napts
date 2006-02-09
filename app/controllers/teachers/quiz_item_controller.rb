class Teachers::QuizItemController < Teachers::BaseController
  verify :method => :get, :only => %w( list )
  verify :method => :post, :only => %w( move_up move_down move_first move_last toggle_preview_status destroy )

  def list
    @quiz = current_subject.quizzes.find(params[:quiz_id])
    if params[:q]
      conditions = ['quiz_items.quiz_id = ? AND questions.content LIKE ?', @quiz.id, "%#{params[:q]}%"]
    else
      conditions = ['quiz_items.quiz_id = ?', @quiz.id]
    end
    @quiz_item_pages, @quiz_items = 
      paginate(:quiz_items, 
               :select => 'quiz_items.*',
               :joins => 'LEFT OUTER JOIN questions ON questions.id = quiz_items.question_id',
               :conditions => conditions,
               :order => 'position',
               :per_page => 10 )
  end

  def toggle_preview_status
    quiz_item = find_quiz_item(params[:id])
    quiz_item.update_attribute(:is_on_test,(params[:preview_status] == 'true'))
    redirect_to(:action => 'list', :quiz_id => quiz_item.quiz_id)
  end  

  def move_up
    quiz_item = find_quiz_item(params[:id])
    quiz_item.move_higher
    redirect_to(:action => 'list', :quiz_id => quiz_item.quiz_id)
  end
  
  def move_down
    quiz_item = find_quiz_item(params[:id])
    quiz_item.move_lower
    redirect_to(:action => 'list', :quiz_id => quiz_item.quiz_id)
  end
  
  def move_first
    quiz_item = find_quiz_item(params[:id])
    quiz_item.move_to_top
    redirect_to(:action => 'list', :quiz_id => quiz_item.quiz_id)
  end
  
  def move_last
    quiz_item = find_quiz_item(params[:id])
    quiz_item.move_to_bottom
    redirect_to(:action => 'list', :quiz_id => quiz_item.quiz_id)
  end

  def destroy
    quiz_item = find_quiz_item(params[:id]).destroy
    redirect_to(:action => 'list', :quiz_id => quiz_item.quiz_id)
  end  

private

  def find_quiz_item(quiz_item_id)
    quiz_item = QuizItem.find(quiz_item_id,
                              :select => 'quiz_items.*',
                              :conditions => [ 'quizzes.subject_id = ?', current_subject.id],
                              :joins => 'LEFT OUTER JOIN quizzes ON quizzes.id = quiz_items.quiz_id',
                              :readonly => false)
    raise ActiveRecord::RecordNotFound, "Couldn't find QuizItem with id = #{params[:id]} AND quizzes.subject_id = #{current_subject.id}" unless quiz_item
    quiz_item
  end
end
