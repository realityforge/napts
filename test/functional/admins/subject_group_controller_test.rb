require File.dirname(__FILE__) + '/../../test_helper'
require 'admins/subject_group_controller'

#Re-raise errors caught by the controller.
class Admins::SubjectGroupController; def rescue_action(e) raise e end; end

class SubjectGroupControllerTest < Test::Unit::TestCase
  fixtures OrderedTables

  #self.use_transactional_fixtures = false
  
  def setup
    @controller = Admins::SubjectGroupController.new
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
    assert_not_nil(assigns(:subject_groups))
    assert_equal(3,assigns(:subject_groups).length)
    assert_equal(@sg_3.id,assigns(:subject_groups)[0].id)
    assert_equal(@sg_1.id,assigns(:subject_groups)[1].id)
    assert_equal(@sg_2.id,assigns(:subject_groups)[2].id)
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
    assert_not_nil(assigns(:subject_group))
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
  
  def test_new_post_with_error
    post(:new, 
        {:subject_group => {:name => ''}}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_response(:success)
    assert_template('new')
    assert_valid_markup
    assert_not_nil(assigns(:subject_group))
    assert_not_nil(assigns(:subject_group).errors[:name])
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
 
  def test_new_post
    post(:new, 
        {:subject_group => {:name => 'X'}}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_redirected_to(:action => 'list')
    assert_not_nil(assigns(:subject_group))
    assert_nil(assigns(:subject_group).errors[:name])
    assert_nil(flash[:alert])
    assert_equal('Subject group was successfully created.',flash[:notice])
  end

  def test_edit_get
    get(:edit, 
        {:id => @sg_1.id}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_response(:success)
    assert_template('edit')
    assert_valid_markup
    assert_not_nil(assigns(:subject_group))
    assert_equal(@sg_1.id,assigns(:subject_group).id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
  
  def test_edit_post_with_error
    post(:edit, 
        {:id => @sg_1.id, :subject_group => {:name => ''}}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_response(:success)
    assert_template('edit')
    assert_valid_markup
    assert_not_nil(assigns(:subject_group))
    assert_equal(@sg_1.id,assigns(:subject_group).id)
    assert_not_nil(assigns(:subject_group).errors[:name])
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
 
  def test_edit_post
    post(:edit, 
        {:id => @sg_1.id, :subject_group => {:name => 'X'}}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_redirected_to(:action => 'list')
    assert_not_nil(assigns(:subject_group))
    assert_equal(@sg_1.id,assigns(:subject_group).id)
    assert_nil(assigns(:subject_group).errors[:name])
    assert_nil(flash[:alert])
    assert_equal('Subject group was successfully updated.',flash[:notice])
  end

  def test_destroy
    post(:destroy, 
        {:id => @sg_1.id}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_redirected_to(:action => 'list')
    assert_nil(flash[:alert])
    assert_equal('Subject group was successfully deleted.',flash[:notice])
    assert(!SubjectGroup.exists?(@sg_1.id))
  end
end
