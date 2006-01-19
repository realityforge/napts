require File.dirname(__FILE__) + '/../../test_helper'
require 'demonstrators/quiz_attempt_controller'

#Re-raise errors caught by the controller.
class Demonstrators::QuizAttemptController; def rescue_action(e) raise e end; end

class QuizAttemptControllerTest < Test::Unit::TestCase
  fixtures OrderedTables
  
  def setup
    @controller = Demonstrators::QuizAttemptController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
  
  def test_list
    get(:list, 
        {:quiz_id => @quiz_3.id}, 
        {:user_id => @mr_fancy_pants_user.id, :role => :demonstrator, :subject_id => @subject_2.id} )
    assert_response(:success)
    assert_template('list')
    assert_valid_markup
    assert_not_nil(assigns(:quiz_attempts))
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
  
  def test_reset
    post(:reset, 
        {:quiz_id => @quiz_3.id, :quiz_attempt_id => @qa_1.id}, 
        {:user_id => @mr_fancy_pants_user.id, :role => :demonstrator, :subject_id => @subject_2.id} )
    assert_redirected_to(:action => 'list', :quiz_id => @quiz_3.id)
    assert_raise(ActiveRecord::RecordNotFound){QuizAttempt.find(@qa_1.id)}
  end
end
