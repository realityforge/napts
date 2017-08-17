require File.dirname(__FILE__) + '/../../test_helper'
require 'teachers/user_controller'

#Re-raise errors caught by the controller.
class Teachers::UserController; def rescue_action(e) raise e end; end

class Teachers::UserControllerTest < Test::Unit::TestCase
  fixtures OrderedTables

  def setup
    @controller = Teachers::UserController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_list
    get(:list,
        {},
        {:user_id => users(:lecturer_user).id,
	 :role => :teacher,
	 :subject_id => subjects(:subject_2).id})
    assert_response(:success)
    assert_template('list')
    assert_valid_markup
    assert_not_nil(assigns(:demonstrators))
    assert_equal(1,assigns(:demonstrators).length)
    assert_equal(users(:mr_fancy_pants_user).id, assigns(:demonstrators)[0].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_list_users
    get(:list_users,
        {},
        {:user_id => users(:lecturer_user).id,
	 :role => :teacher,
	 :subject_id => subjects(:subject_2).id})
    assert_response(:success)
    assert_template('list_users')
    assert_valid_markup
    assert_not_nil(assigns(:users))
    assert_equal(4, assigns(:users).length)
        assert_equal(users(:admin_user).id,assigns(:users)[0].id)
    assert_equal(users(:lecturer_user).id,assigns(:users)[1].id)
    assert_equal(users(:peter_user).id,assigns(:users)[2].id)
    assert_equal(users(:sleepy_user).id,assigns(:users)[3].id)
    assert_not_nil(assigns(:user_pages))
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_add_demonstrator
    assert_raise(ActiveRecord::RecordNotFound){subjects(:subject_2).demonstrators.find(users(:peter_user).id)}
    post(:add_demonstrator,
         {:id => users(:peter_user).id, :q => 's', :page => '1'},
         {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_2).id})
    assert_redirected_to(:action => 'list_users', :q => 's', :page => '1')
    assert_not_nil(assigns(:user))
    assert_equal(users(:peter_user).id, assigns(:user).id)
    assert_nil(flash[:alert])
    assert_equal('Demonstrator was successfully created.', flash[:notice])
    assert_not_nil(subjects(:subject_2).demonstrators.find(users(:peter_user).id))
  end

  def test_remove_demonstrator
    assert_not_nil(subjects(:subject_2).demonstrators.find(users(:mr_fancy_pants_user).id))
    post(:remove_demonstrator,
         {:id => users(:mr_fancy_pants_user).id },
         {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_2).id})
    assert_redirected_to(:action => 'list')
    assert_not_nil(assigns(:user))
    assert_equal(users(:mr_fancy_pants_user).id, assigns(:user).id)
    assert_nil(flash[:alert])
    assert_equal('Demonstrator was successfully removed from Subject.', flash[:notice])
    assert_raise(ActiveRecord::RecordNotFound){subjects(:subject_2).demonstrators.find(users(:mr_fancy_pants_user).id)}
  end
end
