require File.dirname(__FILE__) + '/../../test_helper'
require 'demonstrators/quiz_controller'

#Re-raise errors caught by the controller.
class Demonstrators::QuizController; def rescue_action(e) raise e end; end

class Demonstrators::QuizControllerTest < Test::Unit::TestCase
  fixtures OrderedTables
  
  def setup
    @controller = Demonstrators::QuizController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
  
  def test_list
    get(:list, 
        {}, 
        {:user_id => @peter_user.id, :role => :demonstrator, :subject_id => @subject_1.id} )
    assert_response(:success)
    assert_template('list')
    assert_valid_markup
    assert_not_nil(assigns(:quizzes))
    assert_equal(2,assigns(:quizzes).length)
    assert_equal(@quiz_2.id,assigns(:quizzes)[0].id)
    assert_equal(@quiz_1.id,assigns(:quizzes)[1].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
  
  def test_show
    get(:show, 
        {:id => @quiz_2.id}, 
        {:user_id => @peter_user.id, :role => :demonstrator, :subject_id => @subject_1.id} )
    assert_response(:success)
    assert_template('show')
    assert_valid_markup
    assert_not_nil(assigns(:quiz))
    assert_equal(@quiz_2.id,assigns(:quiz).id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
  
  def test_enable
    post(:enable, 
        {:id => @quiz_1.id}, 
        {:user_id => @peter_user.id, :role => :demonstrator, :subject_id => @subject_1.id} )
    assert_redirected_to(:action => 'show', :id => @quiz_1.id)
    @quiz_1.reload
    assert_equal(true, @quiz_1.enable)
    assert_nil(flash[:alert])
    assert_not_nil(flash[:notice])
  end
  
  def test_disable
    post(:disable, 
        {:id => @quiz_2.id}, 
        {:user_id => @peter_user.id, :role => :demonstrator, :subject_id => @subject_1.id} )
    assert_redirected_to(:action => 'show', :id => @quiz_2.id)
    @quiz_2.reload
    assert_equal(false, @quiz_2.enable)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
end
