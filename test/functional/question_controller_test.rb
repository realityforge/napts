require File.dirname(__FILE__) + '/../test_helper'
require 'question_controller'

# Re-raise errors caught by the controller.
class QuestionController; def rescue_action(e) raise e end; end

class QuestionControllerTest < Test::Unit::TestCase
  fixtures :questions, :answers

  def setup
    @controller = QuestionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_list
    get(:list)
    assert_response(:success)
    assert_template('list')
    assert_not_nil assigns(:questions)
  end

  def test_show
    get(:show, :id => 1)
    assert_response(:success)
    assert_template('show')
    assert_not_nil assigns(:question)
    assert assigns(:question).valid?
  end

  #test get, and answers
  def test_new_get
    num_questions = Question.count
    get(:new)
    assert_response( :success )
    assert_template( 'new' )
    assert_nil( flash[:notice] )
    assert_equal( 4, assigns(:question).answers.length )
    assert_equal( num_questions, Question.count )
  end

  def test_new_post_with_failed_save
    num_questions = Question.count
    content = ''
    post( :new, :question => {:content => content,
                              :question_type => 1 }
	)
    assert_response( :success )
    assert_template( 'new' )
    assert_equal(1,assigns(:question).errors.count)
    assert_not_nil(assigns(:question).errors.on(:content))
    assert_equal( 0, assigns(:question).answers.length )
    assert_equal( num_questions, Question.count )
  end

  #test new qn with data, flash and redirect 
  def test_new_post
    num_questions = Question.count

    content = 'My new content'
    question_type = '1'
    answer_content = 'answer content'
    is_correct = 'true'
    post( :new, :question => {:content => content,
                              :question_type => question_type},
			      :answer => {'this_is_ignored' => 
			      	{:content => answer_content,
				 :is_correct => is_correct} 
			      }
	)
    assert_equal( content, assigns(:question).content )
    assert_equal( 1 , assigns(:question).question_type )
    assert_equal( 1, assigns(:question).answers.length )
    assert_equal( answer_content, assigns(:question).answers[0].content )
    assert_equal( is_correct, assigns(:question).answers[0].is_correct.to_s )
    assert_equal( 'Question was successfully created.', flash[:notice] )
    assert_redirected_to( :action => 'list' )
    assert_equal( num_questions + 1 , Question.count )
  end

  def test_edit_get
    get( :edit, :id => 1 )
    question = Question.find( 1 )
    assert_equal( "Is chocolate good?", question.content )
    assert_equal( 1, question.question_type )
    assert_response( :success )
    assert_nil( flash[:notice] )
    assert_nil( flash[:alert] )
  end  

  def test_edit_post
    question = 'Is chocolate great?'
    answer = 'Maybe, or maybe not'
    post(:edit, :id => 1, 
                :question => {:content => question}, 
		:answer => {1 => { :content => answer }}
	)
    assert_equal( 'Question was successfully updated.', flash[:notice] )
    assert_response( :redirect )
    assert_redirected_to( :action => 'show', :id => 1 )
    a1 = Answer.find( 1 )
    q1 = Question.find( 1 )
    assert_equal( answer, a1.content ) 
    assert_equal( question, q1.content )
  end
  
  def test_edit_post_with_invalid_question
    question = ''
    answer = 'Maybe, maybe not'
    post(:edit, :id => 1, 
                :question => {:content => question}, 
		:answer => {1 => { :content => answer }}
	)
    assert_response( :success )
    assert_template( 'edit' )
    assert_equal( 1, assigns(:question).errors.count )
    assert_not_nil( assigns(:question).errors.on(:content) )
  end
  
  def test_edit_post_invalid_answer
    question = 'Yo dude'
    answer = ''
    
    post(:edit, :id => 1, 
                :question => {:content => question}, 
		:answer => {1 => { :content => answer }}
	)
    assert_response( :success )
    assert_template( 'edit' )
    answer = assigns(:question).answers.detect {|x| x.id == 1}
    assert_equal( 1, answer.errors.count )
    assert_not_nil( answer.errors.on(:content) )
  end
  
  def test_edit_post_with_answer_not_associated_with_question
    question = 'Yo dude'
    answer = 'Hiya'
    post( :edit, :id => 1,
                 :question => {:content => question},
                 :answer => {12 => {:content => answer}}
	)
    assert_response( :success )
    assert_equal( "Update not successful", flash[:alert] )
    assert_template( 'edit' )
  end
  
  def test_destroy
    assert_not_nil( Question.find(1) )
    post( :destroy, :id => 1 )
    assert_response( :redirect )
    assert_redirected_to( :action => 'list' )
    assert_raise(ActiveRecord::RecordNotFound) { Question.find(1) }
  end
end
