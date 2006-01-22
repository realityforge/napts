require File.dirname(__FILE__) + '/../../test_helper'
require 'admins/user_controller'

#Re-raise errors caught by the controller.
class Admins::UserController; def rescue_action(e) raise e end; end

class Admins::UserControllerTest < Test::Unit::TestCase
  fixtures OrderedTables

  def setup
    @controller = Admins::UserController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
  
  def test_list
    get(:list, 
        {}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_response(:success)
    assert_template('list')
    assert_valid_markup
    assert_not_nil(assigns(:users))
    assert_not_nil(assigns(:user_pages))
    assert_equal(5,assigns(:users).length)
    assert_equal(@admin_user.id,assigns(:users)[0].id)
    assert_equal(@lecturer_user.id,assigns(:users)[1].id)
    assert_equal(@mr_fancy_pants_user.id,assigns(:users)[2].id)
    assert_equal(@peter_user.id,assigns(:users)[3].id)
    assert_equal(@sleepy_user.id,assigns(:users)[4].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
  
  def test_new_get
    get(:new, 
        {}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_response(:success)
    assert_template('new')
    assert_valid_markup
    assert_not_nil(assigns(:user))
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
  
  def test_new_post_with_error
    post(:new, 
        {:user => {:name => ''}}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_response(:success)
    assert_template('new')
    assert_valid_markup
    assert_not_nil(assigns(:user))
    assert_not_nil(assigns(:user).errors[:name])
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
 
  def test_new_post
    post(:new, 
        {:user => {:name => 'X'}, :q => 's', :page => '1'}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_not_nil(assigns(:user))
    assert_redirected_to(:action => 'list', :q => 's', :page => '1')
    assert_nil(assigns(:user).errors[:name])
    assert_nil(flash[:alert])
    assert_equal('User was successfully added.',flash[:notice])
  end

  def test_show
    get(:show, 
        {:id => @peter_user.id}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_response(:success)
    assert_template('show')
    assert_valid_markup
    assert_not_nil(assigns(:user))
    assert_equal(@peter_user.id,assigns(:user).id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_toggle_admin_status_to_true
    assert(!@peter_user.administrator?)
    post(:toggle_admin_status, 
        {:id => @peter_user.id, :admin_status => 'true', :q => 's', :page => '1'}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_redirected_to(:action => 'list', :q => 's', :page => '1')
    assert_not_nil(assigns(:user))
    assert_equal(@peter_user.id,assigns(:user).id)
    assert_nil(flash[:alert])
    assert_equal('Admin status successfully updated for User.',flash[:notice])
    assert(assigns(:user).administrator?)
  end

  def test_toggle_admin_status_to_false
    assert(@admin_user.administrator?)
    post(:toggle_admin_status, 
        {:id => @admin_user.id, :admin_status => 'false', :q => 's', :page => '1'}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_redirected_to(:action => 'list', :q => 's', :page => '1')
    assert_not_nil(assigns(:user))
    assert_equal(@admin_user.id,assigns(:user).id)
    assert_nil(flash[:alert])
    assert_equal('Admin status successfully updated for User.',flash[:notice])
    assert(!assigns(:user).administrator?)
  end

  def test_destroy
    assert(User.exists?(@peter_user.id))
    post(:destroy, 
        {:id => @peter_user.id, :q => 's', :page => '1'}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_redirected_to(:action => 'list', :q => 's', :page => '1')
    assert_nil(flash[:alert])
    assert_equal('User was successfully deleted.',flash[:notice])
    assert(!User.exists?(@peter_user.id))
  end
end
