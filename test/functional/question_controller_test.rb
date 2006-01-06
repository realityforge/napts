require File.dirname(__FILE__) + '/../test_helper'
require 'question_controller'

# Re-raise errors caught by the controller.
class QuestionController; def rescue_action(e) raise e end; end

class QuestionControllerTest < Test::Unit::TestCase
  fixtures OrderedTables

  def setup
    @controller = QuestionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_list
  get(:list, {}, { :user_id => @peter_user.id } )
    assert_response(:success)
    assert_template('list')
    assert_valid_markup
    assert_not_nil assigns(:questions)
  end

  def test_show
    get(:show, {:id => 1}, { :user_id => @peter_user.id } )
    assert_response(:success)
    assert_template('show')
    assert_valid_markup
    assert_not_nil assigns(:question)
    assert assigns(:question).valid?
  end

  #test get, and answers
  def test_new_get
    num_questions = Question.count
    get(:new, {}, { :user_id => @peter_user.id } )
    assert_response( :success )
    assert_template( 'new' )
    assert_valid_markup
    assert_nil( flash[:notice] )
    assert_equal( 4, assigns(:question).answers.length )
    assert_equal( num_questions, Question.count )
  end

  def test_new_post_with_failed_save
    num_questions = Question.count
    content = ''
    question_type = 1
    answer_content = 'answer content'
    is_correct = 'true'
    post( :new, {:question => {:content => content,
                              :question_type => question_type },
			      :answer => {'this_is_ignored' => 
			      	{:content => answer_content,
				 :is_correct => is_correct}}},
		{ :user_id => @peter_user.id }
	)
    assert_response( :success )
    assert_template( 'new' )
    assert_valid_markup
    assert_equal(1,assigns(:question).errors.count)
    assert_not_nil(assigns(:question).errors.on(:content))
    assert_equal( 1, assigns(:question).answers.length )
    assert_equal( num_questions, Question.count )
  end

  #test new qn with data, flash and redirect 
  def test_new_post
    num_questions = Question.count

    content = 'My new content'
    question_type = 1
    answer_content = 'answer content'
    is_correct = true
    post( :new, 
         {:question => {:content => content,
                        :question_type => question_type},
			:answer => {'this_is_ignored' => 
			      	  {:content => answer_content,
				   :is_correct => is_correct }}},
	                { :user_id => @peter_user.id }
	)
    assert_equal( content, assigns(:question).content )
    assert_equal( question_type, assigns(:question).question_type )
    assert_equal( 1, assigns(:question).answers.length )
    assert_equal( answer_content, assigns(:question).answers[0].content )
    assert_equal( "true", assigns(:question).answers[0].is_correct.to_s )
    assert_equal( 'Question was successfully created.', flash[:notice] )
    assert_redirected_to( :action => 'list' )
    assert_equal( num_questions + 1 , Question.count )
  end

  def test_edit_get
    get( :edit, {:id => @q1.id},{ :user_id => @peter_user.id } )
    question = Question.find( @q1.id )
    content = "Is chocolate good?"
    question_type = 1
    assert_equal( content, question.content )
    assert_equal( question_type , question.question_type )
    assert_response( :success )
    assert_nil( flash[:notice] )
    assert_nil( flash[:alert] )
  end  

  def test_edit_post
    question = 'Is chocolate great?'
    answer = 'Maybe, or maybe not'
    post(:edit, {'id' => @q1.id, 
                'question' => {'content' => question}, 
		'answer' => {@q1_a1.id.to_s => { 'content' => answer }}},
		{ :user_id => @peter_user.id }
	)
    assert_equal( 'Question was successfully updated.', flash[:notice] )
    assert_response( :redirect )
    assert_redirected_to( :action => 'show', :id => 1 )
    a1 = Answer.find( @q1_a1.id )
    q1 = Question.find( @q1.id )
    assert_equal( answer, a1.content ) 
    assert_equal( question, q1.content )
  end
  
  def test_edit_post_with_invalid_question
    question = ''
    answer = 'Maybe, maybe not'
    post(:edit, {:id => "#{@q1.id}", 
                :question => {:content => question}, 
		:answer => {"#{@q1_a1.id}" => { :content => answer }}},
		{ :user_id => @peter_user.id }
	)
    assert_response(:success)
    assert_template('edit')
    assert_valid_markup
    assert_equal( 1, assigns(:question).errors.count )
    assert_not_nil( assigns(:question).errors.on(:content) )
  end
  
  def test_edit_post_invalid_answer
    question = 'Yo dude'
    answer = ''
    
    post(:edit, {:id => "#{@q1.id}", 
                :question => {:content => question}, 
		:answer => {"#{@q1_a1.id}" => { :content => answer }}},
		  { :user_id => @peter_user.id }
	)
    assert_response( :success )
    assert_template('edit')
    assert_valid_markup
    answer = assigns(:question).answers.detect {|x| x.id == 1}
    assert_equal( 1, answer.errors.count )
    assert_not_nil( answer.errors.on(:content) )
  end
  
  def test_edit_post_with_answer_not_associated_with_question
    question = 'Yo dude'
    answer = 'Hiya'
    post( :edit, { :id => "#{@q2.id}",
                  :question => {:content => question},
                  :answer => { "#{@q4_a1.id}" => {:content => answer}} },
		  { :user_id => @peter_user.id } 
	)
    assert_response( :success )
    assert_equal( "Update not successful", flash[:alert] )
    assert_template( 'edit' )
    assert_valid_markup
  end
#qn already in quizzes so  cannnot be destroyed  
#  def test_destroy
#    assert_not_nil( Question.find(@q3.id) )
#    post( :destroy, {:id => @q3.id}, { :user_id => @peter_user.id } )
#    assert_response( :redirect )
#    assert_nil( flash[:notice] )
#    assert_nil( flash[:alert] )
#    assert_redirected_to( :action => 'list' )
#    assert_raise(ActiveRecord::RecordNotFound) { Question.find(@q3.id) }
#  end
end
