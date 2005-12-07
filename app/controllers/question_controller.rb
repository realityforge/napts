class QuestionController < ApplicationController
  def list
    @question_pages, @questions = paginate :question, :per_page => 10
  end

  def show
    @question = Question.find(params[:id])
  end

  def new
    if request.get?
      @question = Question.new
    else # Assume request.post?
      @question = Question.new(params[:question])
      if @question.save
      	flash[:notice] = 'Question was successfully created.'
	redirect_to :action => 'list'
	return
      end
    end
    @answers = [Answer.new,Answer.new,Answer.new,Answer.new]
  end

  def edit
    @question = Question.find(params[:id])
    if request.post?
      for id in params[:answer].keys
        answer = @question.answers.detect { |x| x.id.to_s == id.to_s }
	if( answer.nil? )
	  flash[:alert] = "Update not successful"
	  return
	else
	  answer.attributes = params[:answer][id]
	  if !answer.valid?
	    return
	  end
	end	  
      end
      @question.answers
      if( @question.update_attributes(params[:question]) &&
          Answer.update( params[:answer].keys, params[:answer].values ) )
        flash[:notice] = 'Question was successfully updated.'
        redirect_to( :action => 'show', :id => @question )
        return
      end
    end
  end

  def destroy
    Question.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
