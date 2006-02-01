require File.dirname(__FILE__) + '/../../test_helper'
require 'students/quiz_attempt_controller'

#Re-raise errors caught by the controller.
class Students::QuizAttemptController; def rescue_action(e) raise e end; end

class Students::QuizAttemptControllerTest < Test::Unit::TestCase
  fixtures OrderedTables

  def setup
    @controller = Students::QuizAttemptController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_list
    get(:list,
        {},
        {:user_id => users(:sleepy_user).id, :role => :student} )
    assert_response(:success)
    assert_template('list')
    assert_valid_markup
    assert_not_nil(assigns(:quizzes))
    assert_equal(1,assigns(:quizzes).length)
    assert_equal(quizzes(:quiz_1).id,assigns(:quizzes)[0].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_start_from_invalid_computer
    post(:start, {:id => quizzes(:quiz_3).id}, {:user_id => users(:peter_user).id, :role => :student})
    assert_redirected_to(:action => 'list')
    assert_equal('Quiz not active for this Computer.',flash[:alert])
    assert_nil(flash[:notice])
  end

end
