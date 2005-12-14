class SubjectsController < ApplicationController
  def index
    list
    render( :action => 'list' )
  end

  def list
    @subject_pages, @subjects = paginate( :subjects, :per_page => 10 )
  end

  def show
    @subject = Subject.find(params[:id])
  end

  def new
    @subject = Subject.new
  end

  def add_quizzes
    @subject = Subject.find(params[:id])
    @quizzes = Quiz.find(:all)
    if request.post?
      for quiz in params[:quiz_ids]
        updatequiz = Quiz.update( :quiz_id => quiz, :subject_id => params[:id] )
      end
    end
  end
    
    
  def create
    @subject = Subject.new(params[:subject])
    if @subject.save
      flash[:notice] = 'Subject was successfully created.'
      redirect_to( :action => 'list' )
    else
      render( :action => 'new' )
    end
  end

  def edit
    @subject = Subject.find(params[:id])
  end

  def update
    @subject = Subject.find(params[:id])
    if @subject.update_attributes(params[:subject])
      flash[:notice] = 'Subject was successfully updated.'
      redirect_to( :action => 'show', :id => @subject )
    else
      render( :action => 'edit' )
    end
  end

  def destroy
    Subject.find(params[:id]).destroy
    redirect_to( :action => 'list' )
  end
end
