require File.dirname(__FILE__) + '/../../test_helper'
require 'teachers/quiz_item_controller'

#Re-raise errors caught by the controller.
class Teachers::QuizItemController; 
  def rescue_action(e) raise e end; 
  def find_quiz_item2 
    @quiz_item = find_quiz_item(params[:id])
    redirect_to(:action => 'list', :quiz_id => @quiz_item.quiz_id)
  end;
end

class Teachers::QuizItemControllerTest < Test::Unit::TestCase
  fixtures OrderedTables

  def setup
    @controller = Teachers::QuizItemController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_find_quiz_item
    get(:find_quiz_item2,
        {:id => quiz_items(:qi_5).id},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id} )
    assert_not_nil(assigns(:quiz_item))
  end

  def test_find_quiz_item_with_non_subject_item
    assert_raises(ActiveRecord::RecordNotFound) do
      get(:find_quiz_item2,
          {:id => quiz_items(:qi_6).id},
          {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id} )
    end
  end

  def test_list
    get(:list,
        {:quiz_id => 1},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id})
    assert_response(:success)
    assert_template('list')
    assert_valid_markup
    assert_not_nil(assigns(:quiz))
    assert_not_nil(assigns(:quiz_item_pages))
    assert_not_nil(assigns(:quiz_items))
    assert_equal(4,assigns(:quiz_items).length)
    assert_equal(quiz_items(:qi_1).id,assigns(:quiz_items)[0].id)
    assert_equal(quiz_items(:qi_2).id,assigns(:quiz_items)[1].id)
    assert_equal(quiz_items(:qi_10).id,assigns(:quiz_items)[2].id)
    assert_equal(quiz_items(:qi_11).id,assigns(:quiz_items)[3].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_move_last
    assert_equal(1,quiz_items(:qi_1).position)
    post(:move_last, 
         {:id => quiz_items(:qi_1).id}, 
         {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id})
    assert_redirected_to(:action => 'list', :quiz_id => quiz_items(:qi_1).quiz_id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
    quiz_items(:qi_1).reload
    assert_equal(4,quiz_items(:qi_1).position)
  end

  def test_move_down
    assert_equal(1,quiz_items(:qi_1).position)
    post(:move_down, 
         {:id => quiz_items(:qi_1).id}, 
         {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id})
    assert_redirected_to(:action => 'list', :quiz_id => quiz_items(:qi_1).quiz_id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
    quiz_items(:qi_1).reload
    assert_equal(2,quiz_items(:qi_1).position)
  end

  def test_move_first
    assert_equal(2,quiz_items(:qi_2).position)
    post(:move_first, 
         {:id => quiz_items(:qi_2).id}, 
         {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id})
    assert_redirected_to(:action => 'list', :quiz_id => quiz_items(:qi_1).quiz_id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
    quiz_items(:qi_2).reload
    assert_equal(1,quiz_items(:qi_2).position)
  end

  def test_move_up
    assert_equal(2,quiz_items(:qi_2).position)
    post(:move_up, 
         {:id => quiz_items(:qi_2).id}, 
         {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id})
    assert_redirected_to(:action => 'list', :quiz_id => quiz_items(:qi_1).quiz_id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
    quiz_items(:qi_2).reload
    assert_equal(1,quiz_items(:qi_2).position)
  end

  def test_destroy 
    post(:destroy, 
         {:id => quiz_items(:qi_2).id}, 
         {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id})
    assert_equal(false, QuizItem.exists?(quiz_items(:qi_2).id))
  end

end
