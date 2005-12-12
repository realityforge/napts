class QuestionController < ApplicationController
  def list
    @question_pages, @questions = paginate( :question, :per_page => 10 )
  end

  def show
    @question = Question.find(params[:id])
  end

  def new
    if request.get?
      @question = Question.new
      @question.answers = [Answer.new,Answer.new,Answer.new,Answer.new]
    elsif request.post?
      @question = Question.new(params[:question])
      is_valid = @question.valid?
      for answer_id in params[:answer].keys
	  data = params[:answer][answer_id].dup
          answer = Answer.new(data)
	  @question.answers << answer 
	  if ! answer.valid?
	    is_valid = false
	  end
	end
      if is_valid && @question.save
        @question.answers.each {|answer| answer.save}
      	flash[:notice] = 'Question was successfully created.'
	redirect_to( :action => 'list' )
	return
      end
    end
    i = 1 
    for answer in @question.answers
        answer.id = i
	i = i + 1
    end
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
      if( @question.update_attributes(params[:question]) &&
          Answer.update( params[:answer].keys, params[:answer].values ) )
        flash[:notice] = 'Question was successfully updated.'
        redirect_to( :action => 'show', :id => @question )
        return
      end
    end
  end

  def destroy
    @question = Question.find(params[:id])
    if @question.quiz_items.length > 0
      flash[:alert] = 'Question in quiz so cannot be destroyed'
    else
      Question.find(params[:id]).destroy
    end
    redirect_to( :action => 'list' )
  end
end
