class QuizAttemptController < ApplicationController
  def intro
    @user = User.find(params[:user_id])
    @quiz = Quiz.find(:all)
  end
  
  def take_test
    @user = User.find(params[:user_id])
    @quiz = Quiz.find(params[:quiz_id])

    @questions = Question.find(:all, 
                             :conditions => ['quiz_items.quiz_id = ?', @quiz.id],
			     :joins => 'LEFT OUTER JOIN quiz_items ON quiz_items.question_id = questions.id ')
#    @quiz_pages, @quizitems = paginate( :quiz_items, :conditions => ['quiz_id = ? ', @qi.id ], :per_page => 1 )
  end
end
