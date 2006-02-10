require File.dirname(__FILE__) + '/../../test_helper'
require 'teachers/resource_controller'

#Re-raise errors caught by the controller.
class Teachers::ResourceController; def rescue_action(e) raise e end; end

module UploadedFile
  attr_accessor :original_filename, :content_type
end


class Teachers::ResourceControllerTest < Test::Unit::TestCase
  fixtures OrderedTables

  def setup
    @controller = Teachers::ResourceController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_list
    get(:list,
        {},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_2).id})
    assert_response(:success)
    assert_template('list')
    assert_valid_markup
    assert_not_nil(assigns(:resource_pages))
    assert_not_nil(assigns(:resources))
    assert_equal(2,assigns(:resources).length)
    assert_equal(resources(:resource_2).id,assigns(:resources)[0].id)
    assert_equal(resources(:resource_4).id,assigns(:resources)[1].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_list_with_query
    get(:list,
        {:q => 'ig'},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_2).id})
    assert_response(:success)
    assert_template('list')
    assert_valid_markup
    assert_not_nil(assigns(:resource_pages))
    assert_not_nil(assigns(:resources))
    assert_equal(1,assigns(:resources).length)
    assert_equal(resources(:resource_2).id,assigns(:resources)[0].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_new_get
    get(:new,
        {},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_2).id})
    assert_response(:success)
    assert_template('new')
    assert_valid_markup
    assert_not_nil(assigns(:resource))
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_new_post_with_error
    post(:new,
        {:resource => {:description => 'Y', :data => uploaded_file('Blahblah', '', 'text/plain')}},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_2).id})
    assert_response(:success)
    assert_template('new')
    assert_valid_markup
    assert_not_nil(assigns(:resource))
    assert_not_nil(assigns(:resource).errors[:name])
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_new_post
    post(:new,
        {:resource => {:description => 'Y', :data => uploaded_file('Blahblah', '/some/path/README.txt', 'text/plain')}},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_2).id})
    assert_not_nil(assigns(:resource))
    assert_redirected_to(:action => 'show', :id => assigns(:resource).id)
    assert_nil(flash[:alert])
    assert_equal('Resource was successfully created.',flash[:notice])
    assigns(:resource).reload
    assert_equal('README.txt',assigns(:resource).name)
    assert_equal('text/plain',assigns(:resource).content_type)
    assert_equal('Y',assigns(:resource).description)
  end

  def test_show
    get(:show,
        {:id => resources(:resource_2).id},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_2).id})
    assert_response(:success)
    assert_template('show')
    assert_valid_markup
    assert_not_nil(assigns(:resource))
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_edit_get
    get(:edit,
        {:id => resources(:resource_2).id},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_2).id})
    assert_response(:success)
    assert_template('edit')
    assert_valid_markup
    assert_not_nil(assigns(:resource))
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_edit_post
    post(:edit,
        {:id => resources(:resource_2).id, :resource => {:description => 'Y'}},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_2).id})
    assert_not_nil(assigns(:resource))
    assert_redirected_to(:action => 'show', :id => assigns(:resource).id)
    assert_nil(flash[:alert])
    assert_equal('Resource was successfully updated.',flash[:notice])
    assigns(:resource).reload
    assert_equal('Y',assigns(:resource).description)
  end

  def test_view_inline
    get(:view,
        {:id => resources(:resource_2).id},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_2).id})
    assert_response(:success)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
    assert_equal("inline; filename=\"#{resources(:resource_2).name}\"", @response.headers['Content-Disposition'])
    assert_equal(resources(:resource_2).content_type, @response.headers['Content-Type'])
  end

  def test_view_download
    get(:view,
        {:id => resources(:resource_2).id, :disposition => 'download'},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_2).id})
    assert_response(:success)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
    assert_equal("download; filename=\"#{resources(:resource_2).name}\"", @response.headers['Content-Disposition'])
    assert_equal(resources(:resource_2).content_type, @response.headers['Content-Type'])
  end

  def test_destroy 
    post(:destroy, 
         {:id => resources(:resource_1).id, :q => 'q', :page => '1'}, 
         {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id})
    assert_redirected_to(:action => 'list', :q => 'q', :page => '1')
    assert_nil(flash[:alert])
    assert_equal('Resource was successfully deleted.',flash[:notice])
    assert_equal(false, Resource.exists?(resources(:resource_1).id))
  end

private
  def uploaded_file(contents, name, content_type)
    io = StringIO.new(contents)
    io.extend UploadedFile
    io.original_filename = name
    io.content_type = content_type
    io
  end
end
