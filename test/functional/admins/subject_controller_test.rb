require File.dirname(__FILE__) + '/../../test_helper'
require 'admins/subject_controller'

#Re-raise errors caught by the controller.
class Admins::SubjectController; def rescue_action(e) raise e end; end

class Admins::SubjectControllerTest < Test::Unit::TestCase
  fixtures OrderedTables

  def setup
    @controller = Admins::SubjectController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_list
    get(:list,
        {},
        {:user_id => users(:admin_user).id, :role => :administrator} )
    assert_response(:success)
    assert_template('list')
    assert_valid_markup
    assert_not_nil(assigns(:subjects))
    assert_equal(3,assigns(:subjects).length)
    assert_equal(subjects(:subject_2).id,assigns(:subjects)[0].id)
    assert_equal(subjects(:subject_1).id,assigns(:subjects)[1].id)
    assert_equal(subjects(:subject_3).id,assigns(:subjects)[2].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_list_with_query
    get(:list,
        {:q => 'ADS'},
        {:user_id => users(:admin_user).id, :role => :administrator} )
    assert_response(:success)
    assert_template('list')
    assert_valid_markup
    assert_not_nil(assigns(:subjects))
    assert_equal(1,assigns(:subjects).length)
    assert_equal(subjects(:subject_1).id,assigns(:subjects)[0].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_new_get
    get(:new,
        {},
        {:user_id => users(:admin_user).id, :role => :administrator} )
    assert_response(:success)
    assert_template('new')
    assert_valid_markup
    assert_not_nil(assigns(:subject))
    assert_not_nil(assigns(:groups))
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_new_post_with_error
    post(:new,
        {:subject_ => {:name => '', :subject_group_id => subject_groups(:sg_1).id}},
        {:user_id => users(:admin_user).id, :role => :administrator} )
    assert_response(:success)
    assert_template('new')
    assert_valid_markup
    assert_not_nil(assigns(:groups))
    assert_not_nil(assigns(:subject))
    assert_not_nil(assigns(:subject).errors[:name])
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_new_post
    post(:new,
        {:subject => {:name => 'X', :subject_group_id => subject_groups(:sg_1).id}},
        {:user_id => users(:admin_user).id, :role => :administrator} )
    assert_not_nil(assigns(:subject))
    assert_redirected_to(:action => 'show', :id => assigns(:subject).id)
    assert_nil(assigns(:subject).errors[:name])
    assert_nil(flash[:alert])
    assert_equal('Subject was successfully created.',flash[:notice])
  end

  def test_show
    get(:show,
        {:id => subjects(:subject_1).id},
        {:user_id => users(:admin_user).id, :role => :administrator} )
    assert_response(:success)
    assert_template('show')
    assert_valid_markup
    assert_not_nil(assigns(:subject))
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_edit_get
    get(:edit,
        {:id => subjects(:subject_1).id},
        {:user_id => users(:admin_user).id, :role => :administrator} )
    assert_response(:success)
    assert_template('edit')
    assert_valid_markup
    assert_not_nil(assigns(:subject))
    assert_equal(subjects(:subject_1).id,assigns(:subject).id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_edit_post_with_error
    post(:edit,
        {:id => subjects(:subject_1).id, :subject => {:name => '', :subject_group_id => subject_groups(:sg_1).id}},
        {:user_id => users(:admin_user).id, :role => :administrator} )
    assert_response(:success)
    assert_template('edit')
    assert_valid_markup
    assert_not_nil(assigns(:subject))
    assert_equal(subjects(:subject_1).id,assigns(:subject).id)
    assert_not_nil(assigns(:subject).errors[:name])
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_edit_post
    post(:edit,
        {:id => subjects(:subject_1).id, :subject => {:name => 'X', :subject_group_id => subject_groups(:sg_1).id}},
        {:user_id => users(:admin_user).id, :role => :administrator} )
    assert_not_nil(assigns(:subject))
    assert_redirected_to(:action => 'show', :id => subjects(:subject_1).id)
    assert_equal(subjects(:subject_1).id,assigns(:subject).id)
    assert_nil(assigns(:subject).errors[:name])
    assert_nil(flash[:alert])
    assert_equal('Subject was successfully updated.',flash[:notice])
  end

  def test_teachers
    get(:teachers,
        {:id => subjects(:subject_1).id},
        {:user_id => users(:admin_user).id, :role => :administrator} )
    assert_response(:success)
    assert_template('teachers')
    assert_valid_markup
    assert_not_nil(assigns(:subject))
    assert_equal(subjects(:subject_1).id,assigns(:subject).id)
    assert_not_nil(assigns(:users))
    assert_equal(4,assigns(:users).length)
    assert_equal(users(:admin_user).id,assigns(:users)[0].id)
    assert_equal(users(:mr_fancy_pants_user).id,assigns(:users)[1].id)
    assert_equal(users(:peter_user).id,assigns(:users)[2].id)
    assert_equal(users(:sleepy_user).id,assigns(:users)[3].id)
    assert_not_nil(assigns(:user_pages))
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_add_teacher
    assert_raise(ActiveRecord::RecordNotFound){subjects(:subject_1).teachers.find(users(:peter_user).id)}
    post(:add_teacher,
        {:id => subjects(:subject_1).id, :user_id => users(:peter_user).id, :q => 's', :page => '1'},
        {:user_id => users(:admin_user).id, :role => :administrator} )
    assert_redirected_to(:action => 'teachers', :id => subjects(:subject_1).id, :q => 's', :page => '1')
    assert_not_nil(assigns(:subject))
    assert_equal(subjects(:subject_1).id,assigns(:subject).id)
    assert_not_nil(assigns(:user))
    assert_equal(users(:peter_user).id,assigns(:user).id)
    assert_nil(flash[:alert])
    assert_equal('Teacher was successfully added to Subject.',flash[:notice])
    assert_not_nil(subjects(:subject_1).teachers.find(users(:peter_user).id))
  end

  def test_remove_teacher
    assert_not_nil(subjects(:subject_1).teachers.find(users(:lecturer_user).id))
    post(:remove_teacher,
        {:id => subjects(:subject_1).id, :user_id => users(:lecturer_user).id},
        {:user_id => users(:admin_user).id, :role => :administrator} )
    assert_redirected_to(:action => 'show', :id => subjects(:subject_1).id)
    assert_not_nil(assigns(:subject))
    assert_equal(subjects(:subject_1).id,assigns(:subject).id)
    assert_not_nil(assigns(:user))
    assert_equal(users(:lecturer_user).id,assigns(:user).id)
    assert_nil(flash[:alert])
    assert_equal('Teacher was successfully removed from Subject.',flash[:notice])
    assert_raise(ActiveRecord::RecordNotFound){subjects(:subject_1).teachers.find(users(:lecturer_user).id)}
  end

  def test_destroy
    post(:destroy,
        {:id => subjects(:subject_1).id, :q => 's', :page => '1'},
        {:user_id => users(:admin_user).id, :role => :administrator} )
    assert_redirected_to(:action => 'list', :q => 's', :page => '1')
    assert_nil(flash[:alert])
    assert_equal('Subject was successfully deleted.',flash[:notice])
    assert(!Subject.exists?(subjects(:subject_1).id))
  end
end
