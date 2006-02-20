require File.dirname(__FILE__) + '/../../test_helper'
require 'students/preview_controller'

#Re-raise errors caught by the controller.
class Students::PreviewController; def rescue_action(e) raise e end; end

class Students::PreviewControllerTest < Test::Unit::TestCase
  fixtures OrderedTables

  def setup
    @controller = Students::PreviewController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_list
    get(:list,
        {:subject_id => subjects(:subject_1).id},
        {:user_id => users(:peter_user).id, :role => :student} )
    assert_response(:success)
    assert_template('list')
    assert_valid_markup
    assert_not_nil(assigns(:subject))
    assert_not_nil(assigns(:quizzes))
    assert_equal(2,assigns(:quizzes).length)
    assert_equal(quizzes(:quiz_2).id,assigns(:quizzes)[0].id)
    assert_equal(quizzes(:quiz_1).id,assigns(:quizzes)[1].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_show
    get(:show,
        {:id => quizzes(:quiz_1).id},
        {:user_id => users(:peter_user).id, :role => :student} )
    assert_response(:success)
    assert_template('show')
    assert_valid_markup
    assert_not_nil(assigns(:quiz))
    assert_equal(quizzes(:quiz_1).id,assigns(:quiz).id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_show_question
    get(:show_question,
        {:id => quizzes(:quiz_1).id, :position => '1'},
        {:user_id => users(:peter_user).id, :role => :student} )
    assert_response(:success)
    assert_template('show_question')
    assert_valid_markup
    assert_not_nil(assigns(:quiz_item))
    assert_equal(quiz_items(:qi_1).id,assigns(:quiz_item).id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_show_question_with_oob_position
    assert_raises(ActiveRecord::RecordNotFound){
      get(:show_question,
          {:id => quizzes(:quiz_1).id, :position => '100'},
          {:user_id => users(:peter_user).id, :role => :student} )
    }
  end
end
