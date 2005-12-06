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
  
  
#  def test_index
#    get :index
#    assert_response :success
#    assert_template 'list'
#  end
#
#  def test_list
#    get :list
#
#    assert_response :success
#    assert_template 'list'
#
#    assert_not_nil assigns(:questions)
#  end
#
#  def test_show
#
#    assert_response :success
#    assert_template 'show'
#
#   assert_not_nil assigns(:question)
#    assert assigns(:question).valid?
#  end
#
#  def test_new
#    get :new
#
#    assert_response :success
#    assert_template 'new'
#
#    assert_not_nil assigns(:question)
#  end

  def test_new
    num_questions = Question.count
    post :new, :question => {}
    assert_response( :success )
    assert_equal(1,assigns(:question).errors.count)
    assert_not_nil(assigns(:question).errors.on(:content))
    assert_template('new')
    assert_nil( flash[:notice] )
    assert_equal( 4, assigns(:answers).length )
    #assert_redirected_to( :action => 'list' )
    #assert_equal( num_questions + 1, Question.count )
  end
  
#  def test_edit
#    get :edit, :id => 1
#    assert_response( :success )
#    assert_template( 'edit' )
#    assert_not_nil( assigns(:question) )
#    assert( assigns(:question).valid? )
#  end
  
  def test_edit_updates
  post :edit, :id => 1, :question => {:content => 'Is chocolate good?'}, :answer => {1 => { :content => 'Yes, for sure!' }}
    assert_response( :redirect )
    assert_redirected_to( :action => 'show', :id => 1 )
  end

#  def test_create
#    num_questions = Question.count
#
#    post :create, :question => {}
#
#    assert_response :redirect
#    assert_redirected_to :action => 'list'
#
#    assert_equal num_questions + 1, Question.count
#  end
#
#  def test_edit
#    get :edit, :id => 1
#
#    assert_response :success
#    assert_template 'edit'
#
#    assert_not_nil assigns(:question)
#    assert assigns(:question).valid?
#  end
#
#  def test_update
#    post :update, :id => 1
#    assert_response :redirect
#    assert_redirected_to :action => 'show', :id => 1
#  end
#
#  def test_destroy
#    assert_not_nil Question.find(1)
#
#    post :destroy, :id => 1
#    assert_response :redirect
#    assert_redirected_to :action => 'list'
#
#    assert_raise(ActiveRecord::RecordNotFound) {
#      Question.find(1)
#    }
#  end
end
