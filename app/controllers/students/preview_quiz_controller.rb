class PreviewQuizController < ApplicationController
  def intro
    @quiz = Quiz.find( :all, :conditions => ['prelim_enable = ?', true] )
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
      redirect_to( :action => 'intro' )
    end
  end
end
