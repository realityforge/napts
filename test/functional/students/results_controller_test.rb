require File.dirname(__FILE__) + '/../../test_helper'
require 'students/results_controller'

#Re-raise errors caught by the controller.
class Students::ResultsController; def rescue_action(e) raise e end; end

class Students::ResultsControllerTest < Test::Unit::TestCase
  fixtures OrderedTables

  def setup
    @controller = Students::ResultsController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_list
    get(:list,
        {:id => subjects(:subject_1).id},
        {:user_id => users(:mr_fancy_pants_user).id, :role => :student} )
    assert_response(:success)
    assert_template('list')
    assert_valid_markup
    assert_not_nil(assigns(:quiz_attempts))
    assert_equal(2,assigns(:quiz_attempts).length)
    assert_equal(quiz_attempts(:qa_3).id,assigns(:quiz_attempts)[0].id)
    assert_equal(quiz_attempts(:qa_6).id,assigns(:quiz_attempts)[1].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_show
    get(:show,
        {:id => quiz_attempts(:qa_1).id},
        {:user_id => users(:peter_user).id, :role => :student} )
    assert_response(:success)
    assert_template('show')
    assert_valid_markup
    assert_not_nil(assigns(:quiz_attempt))
    assert_equal(quiz_attempts(:qa_1).id, assigns(:quiz_attempt).id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
end
