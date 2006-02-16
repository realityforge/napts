require File.dirname(__FILE__) + '/../../test_helper'
require 'teachers/question_controller'

#Re-raise errors caught by the controller.
class Teachers::QuestionController; def rescue_action(e) raise e end; end

class Teachers::QuestionControllerTest < Test::Unit::TestCase
  fixtures OrderedTables

  def setup
    @controller = Teachers::QuestionController.new
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
    assert_not_nil(assigns(:question_pages))
    assert_not_nil(assigns(:questions))
    assert_equal(3,assigns(:questions).length)
    assert_equal(questions(:q4).id,assigns(:questions)[0].id)
    assert_equal(questions(:q5).id,assigns(:questions)[1].id)
    assert_equal(questions(:q6).id,assigns(:questions)[2].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_list_with_query
    get(:list,
        {:q => 'hay'},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_2).id})
    assert_response(:success)
    assert_template('list')
    assert_valid_markup
    assert_not_nil(assigns(:question_pages))
    assert_not_nil(assigns(:questions))
    assert_equal(1,assigns(:questions).length)
    assert_equal(questions(:q4).id,assigns(:questions)[0].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_show
    get(:show,
        {:id => questions(:q1).id},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id})
    assert_response(:success)
    assert_template('show')
    assert_valid_markup
    assert_not_nil(assigns(:question))
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end






  def test_list_resources
    get(:list_resources,
        {:id => questions(:q2).id},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id})
    assert_response(:success)
    assert_template('list_resources')
    assert_valid_markup
    assert_not_nil(assigns(:resource_pages))
    assert_not_nil(assigns(:resources))
    assert_equal(1,assigns(:resources).length)
    assert_equal(resources(:resource_1).id,assigns(:resources)[0].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_list_resources_with_query
    get(:list_resources,
        {:id => questions(:q2).id, :q => 'lu'},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id})
    assert_response(:success)
    assert_template('list_resources')
    assert_valid_markup
    assert_not_nil(assigns(:resource_pages))
    assert_not_nil(assigns(:resources))
    assert_equal(1,assigns(:resources).length)
    assert_equal(resources(:resource_1).id,assigns(:resources)[0].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_add_resource
    assert_nil(questions(:q2).resources.find(:first, :conditions => ['id = ?', resources(:resource_1).id]))
    post(:add_resource, 
         {:id => questions(:q2).id, :resource_id => resources(:resource_1).id}, 
         {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id})
    assert_redirected_to(:action => 'list_resources', :id => questions(:q2).id)
    assert_nil(flash[:alert])
    assert_equal('Resource was successfully added to question.',flash[:notice])
    assert_not_nil(questions(:q2).resources.find(:first, :conditions => ['id = ?', resources(:resource_1).id]))
  end

  def test_remove_resource
    assert_not_nil(questions(:q1).resources.find(:first, :conditions => ['id = ?', resources(:resource_1).id]))
    post(:remove_resource, 
         {:id => questions(:q1).id, :resource_id => resources(:resource_1).id}, 
         {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id})
    assert_redirected_to(:action => 'show', :id => questions(:q1).id)
    assert_nil(flash[:alert])
    assert_equal('Resource was successfully removed from question.',flash[:notice])
    assert_nil(questions(:q1).resources.find(:first, :conditions => ['id = ?', resources(:resource_1).id]))
  end

  def test_destroy_that_fails
    assert_equal(true, Question.exists?(questions(:q1).id))
    post(:destroy, 
         {:id => questions(:q1).id, :q => 'q', :page => '1'}, 
         {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id})
    assert_redirected_to(:action => 'list', :q => 'q', :page => '1')
    assert_nil(flash[:notice])
    assert_equal('Question in quiz so cannot be deleted.',flash[:alert])
    assert_equal(true, Question.exists?(questions(:q1).id))
  end

  def test_destroy 
    assert_equal(true, Question.exists?(questions(:q10).id))
    post(:destroy, 
         {:id => questions(:q10).id, :q => 'q', :page => '1'}, 
         {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id})
    assert_redirected_to(:action => 'list', :q => 'q', :page => '1')
    assert_nil(flash[:alert])
    assert_equal('Question was successfully deleted.',flash[:notice])
    assert_equal(false, Question.exists?(questions(:q10).id))
  end
end
