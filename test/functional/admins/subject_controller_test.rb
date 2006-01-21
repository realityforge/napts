require File.dirname(__FILE__) + '/../../test_helper'
require 'admins/subject_controller'

#Re-raise errors caught by the controller.
class Admins::SubjectController; def rescue_action(e) raise e end; end

class SubjectControllerTest < Test::Unit::TestCase
  fixtures OrderedTables

  def setup
    @controller = Admins::SubjectController.new
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
    assert_not_nil(assigns(:subjects))
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
    assert_not_nil(assigns(:subject))
    assert_not_nil(assigns(:groups))
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
  
  def test_new_post_with_error
    post(:new, 
        {:subject_ => {:code => '', :subject_group_id => @sg_1.id}}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_response(:success)
    assert_template('new')
    assert_valid_markup
    assert_not_nil(assigns(:groups))
    assert_not_nil(assigns(:subject))
    assert_not_nil(assigns(:subject).errors[:code])
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
 
  def test_new_post
    post(:new, 
        {:subject => {:code => 'X', :subject_group_id => @sg_1.id}}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_redirected_to(:action => 'list')
    assert_not_nil(assigns(:subject))
    assert_nil(assigns(:subject).errors[:code])
    assert_nil(flash[:alert])
    assert_equal('Subject was successfully created.',flash[:notice])
  end
  
  def test_edit_get
    get(:edit, 
        {:id => @subject_1.id}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_response(:success)
    assert_template('edit')
    assert_valid_markup
    assert_not_nil(assigns(:subject))
    assert_equal(@subject_1.id,assigns(:subject).id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
  
  def test_edit_post_with_error
    post(:edit, 
        {:id => @subject_1.id, :subject => {:code => '', :subject_group_id => @sg_1.id}}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_response(:success)
    assert_template('edit')
    assert_valid_markup
    assert_not_nil(assigns(:subject))
    assert_equal(@subject_1.id,assigns(:subject).id)
    assert_not_nil(assigns(:subject).errors[:code])
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
 
  def test_edit_post
    post(:edit, 
        {:id => @subject_1.id, :subject => {:code => 'X', :subject_group_id => @sg_1.id}}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_redirected_to(:action => 'list')
    assert_not_nil(assigns(:subject))
    assert_equal(@subject_1.id,assigns(:subject).id)
    assert_nil(assigns(:subject).errors[:code])
    assert_nil(flash[:alert])
    assert_equal('Subject was successfully updated.',flash[:notice])
  end

  def test_destroy
    post(:destroy, 
        {:id => @subject_1.id}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_redirected_to(:action => 'list')
    assert_nil(flash[:alert])
    assert_equal('Subject was successfully deleted.',flash[:notice])
    assert(!Subject.exists?(@subject_1.id))
  end
end
