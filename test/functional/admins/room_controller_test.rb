require File.dirname(__FILE__) + '/../../test_helper'
require 'admins/room_controller'

#Re-raise errors caught by the controller.
class Admins::RoomController; def rescue_action(e) raise e end; end

class Admins::RoomControllerTest < Test::Unit::TestCase
  fixtures OrderedTables

  def setup
    @controller = Admins::RoomController.new
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
    assert_not_nil(assigns(:rooms))
    assert_not_nil(assigns(:room_pages))
    assert_equal(2,assigns(:rooms).length)
    assert_equal(@room_1.id,assigns(:rooms)[0].id)
    assert_equal(@room_2.id,assigns(:rooms)[1].id)
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
    assert_not_nil(assigns(:room))
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
  
  def test_new_post_with_error
    post(:new, 
        {:room_ => {:name => ''}}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_response(:success)
    assert_template('new')
    assert_valid_markup
    assert_not_nil(assigns(:room))
    assert_not_nil(assigns(:room).errors[:name])
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
 
  def test_new_post
    post(:new, 
        {:room => {:name => 'X', :addresses => '1.2.3.4 5.6.7.8 9.0.1.2'}}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_not_nil(assigns(:room))
    assert_redirected_to(:action => 'show', :id => assigns(:room).id)
    assert_nil(assigns(:room).errors[:name])
    assert_nil(flash[:alert])
    assert_equal('Room was successfully created.',flash[:notice])
    assigns(:room).reload
    assert_equal(3,assigns(:room).computers.length)
    assert_equal('1.2.3.4',assigns(:room).computers[0].ip_address)
    assert_equal('5.6.7.8',assigns(:room).computers[1].ip_address)
    assert_equal('9.0.1.2',assigns(:room).computers[2].ip_address)
  end

  def test_show
    get(:show, 
        {:id => @room_1.id}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_response(:success)
    assert_template('show')
    assert_valid_markup
    assert_not_nil(assigns(:room))
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
  
  def test_edit_get
    get(:edit, 
        {:id => @room_1.id}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_response(:success)
    assert_template('edit')
    assert_valid_markup
    assert_not_nil(assigns(:room))
    assert_equal(@room_1.id,assigns(:room).id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
  
  def test_edit_post_with_error
    post(:edit, 
        {:id => @room_1.id, :room => {:name => ''}}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_response(:success)
    assert_template('edit')
    assert_valid_markup
    assert_not_nil(assigns(:room))
    assert_equal(@room_1.id,assigns(:room).id)
    assert_not_nil(assigns(:room).errors[:name])
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
 
  def test_edit_post
    post(:edit, 
        {:id => @room_1.id, :room => {:name => 'X', :addresses => '1.2.3.4 5.6.7.8 9.0.1.2'}}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_not_nil(assigns(:room))
    assert_redirected_to(:action => 'show', :id => @room_1.id)
    assert_equal(@room_1.id,assigns(:room).id)
    assert_nil(assigns(:room).errors[:name])
    assert_nil(flash[:alert])
    assert_equal('Room was successfully updated.',flash[:notice])
    assigns(:room).reload
    assert_equal(3,assigns(:room).computers.length)
    assert_equal('1.2.3.4',assigns(:room).computers[0].ip_address)
    assert_equal('5.6.7.8',assigns(:room).computers[1].ip_address)
    assert_equal('9.0.1.2',assigns(:room).computers[2].ip_address)
  end

  def test_destroy
    post(:destroy, 
        {:id => @room_1.id}, 
        {:user_id => @admin_user.id, :role => :administrator} )
    assert_redirected_to(:action => 'list')
    assert_nil(flash[:alert])
    assert_equal('Room was successfully deleted.',flash[:notice])
    assert(!Room.exists?(@room_1.id))
  end
end
