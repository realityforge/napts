class QuizzesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  def list
    @quiz_pages, @quizzes = paginate :quizzes, :per_page => 10
  end

  def show
    @quiz = Quiz.find(params[:id])
  end

  def new
    @quiz = Quiz.new
  end

  def create
    @quiz = Quiz.new(params[:quiz])
    if @quiz.save
      flash[:notice] = 'Quiz was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @quiz = Quiz.find(params[:id])
  end

  def update
    @quiz = Quiz.find(params[:id])
    if @quiz.update_attributes(params[:quiz])
      flash[:notice] = 'Quiz was successfully updated.'
      redirect_to :action => 'show', :id => @quiz
    else
      render :action => 'edit'
    end
  end

  def destroy
    Quiz.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def add_questions
    @quiz = Quiz.find(params[:id])
    @questions = Question.find(:all)
    if request.post?
    
#    if( QuizItem.update( params[:quiz_item].keys, params[:answer].values ) )
#      flash[:notice] = 'Questions were successfully added'
#      redirect_to( :action => 'show', :id => @quiz )
#    end
  end
  
end
