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
        {:user_id => users(:peter_user).id, :role => :demonstrator, :subject_id => subjects(:subject_1).id} )
    assert_response(:success)
    assert_template('list')
    assert_valid_markup
    assert_not_nil(assigns(:quizzes))
    assert_equal(2,assigns(:quizzes).length)
    assert_equal(quizzes(:quiz_1).id,assigns(:quizzes)[0].id)
    assert_equal(quizzes(:quiz_2).id,assigns(:quizzes)[1].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_list_with_query
    get(:list,
        {:q => 'oa'},
        {:user_id => users(:peter_user).id,
	 :role => :demonstrator,
	 :subject_id => subjects(:subject_1).id} )
    assert_response(:success)
    assert_template('list')
    assert_valid_markup
    assert_not_nil(assigns(:quizzes))
    assert_equal(1,assigns(:quizzes).length)
    assert_equal(quizzes(:quiz_2).id,assigns(:quizzes)[0].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_show
    get(:show,
        {:id => quizzes(:quiz_2).id},
        {:user_id => users(:peter_user).id,
	 :role => :demonstrator,
	 :subject_id => subjects(:subject_1).id} )
    assert_response(:success)
    assert_template('show')
    assert_valid_markup
    assert_not_nil(assigns(:quiz))
    assert_equal(quizzes(:quiz_2).id,assigns(:quiz).id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_list_rooms
    get(:list_rooms,
        {:id => quizzes(:quiz_1).id},
        {:user_id => users(:peter_user).id,
	 :role => :demonstrator,
	 :subject_id => subjects(:subject_1).id} )
    assert_response(:success)
    assert_template('list_rooms')
    assert_valid_markup
    assert_not_nil(assigns(:quiz))
    assert_equal(quizzes(:quiz_1).id,assigns(:quiz).id)
    assert_not_nil(assigns(:rooms))
    assert_not_nil(assigns(:room_pages))
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_enable_room_with_false
    assert_not_nil(quizzes(:quiz_1).active_in.find(:first, :conditions => "id = #{rooms(:room_1).id}"))
    post(:enable_room,
        {:id => quizzes(:quiz_1).id, :room_id => rooms(:room_1).id, :enable => false, :q => 'blah'},
        {:user_id => users(:peter_user).id,
	 :role => :demonstrator,
	 :subject_id => subjects(:subject_1).id} )
    assert_redirected_to(:action => 'list_rooms', :id => quizzes(:quiz_1).id, :q => 'blah')
    quizzes(:quiz_1).reload
    assert_nil(quizzes(:quiz_1).active_in.find(:first, :conditions => "id = #{rooms(:room_1).id}"))
    assert_nil(flash[:alert])
    assert_equal('Update of enabled Rooms for Quiz was successful.',flash[:notice])
  end

  def test_enable_room_with_true
    quizzes(:quiz_1).active_in.clear
    assert_nil(quizzes(:quiz_1).active_in.find(:first, :conditions => "id = #{rooms(:room_2).id}"))
    post(:enable_room,
        {:id => quizzes(:quiz_1).id, :room_id => rooms(:room_2).id, :enable => true, :q => 'blah'},
        {:user_id => users(:peter_user).id,
	 :role => :demonstrator,
	 :subject_id => subjects(:subject_1).id} )
    assert_redirected_to(:action => 'list_rooms', :id => quizzes(:quiz_1).id, :q => 'blah')
    quizzes(:quiz_1).reload
    assert_not_nil(quizzes(:quiz_1).active_in.find(:first, :conditions => "id = #{rooms(:room_2).id}"))
    assert_nil(flash[:alert])
    assert_equal('Update of enabled Rooms for Quiz was successful.',flash[:notice])
  end

#    quizzes(:quiz_1).reload
#    assert_equal(2, quizzes(:quiz_1).active_in.length)
#    assert_not_nil(quizzes(:quiz_1).active_in.find(:first, :conditions => "id = #{rooms(:room_1).id}"))
#    assert_not_nil(quizzes(:quiz_1).active_in.find(:first, :conditions => "id = #{rooms(:room_2).id}"))
#    assert_nil(flash[:alert])
#    assert_equal('Update of enabled Rooms for Quiz was successful.',flash[:notice])
#  end
end
