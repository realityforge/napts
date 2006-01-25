require File.dirname(__FILE__) + '/../../test_helper'
require 'students/subject_controller'

#Re-raise errors caught by the controller.
class Students::SubjectController; def rescue_action(e) raise e end; end

class Students::SubjectControllerTest < Test::Unit::TestCase
  fixtures OrderedTables

  def setup
    @controller = Students::SubjectController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
  
  def test_list
    get(:list, 
        {}, 
        {:user_id => @peter_user.id, :role => :student} )
    assert_response(:success)
    assert_template('list')
    assert_valid_markup
    assert_not_nil(assigns(:subjects))
    assert_equal(3,assigns(:subjects).length)
    assert_equal(@subject_2.id,assigns(:subjects)[0].id)
    assert_equal(@subject_1.id,assigns(:subjects)[1].id)
    assert_equal(@subject_3.id,assigns(:subjects)[2].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_list_with_query
    get(:list, 
        {:q => 'ADS'}, 
        {:user_id => @peter_user.id, :role => :student} )
    assert_response(:success)
    assert_template('list')
    assert_valid_markup
    assert_not_nil(assigns(:subjects))
    assert_equal(1,assigns(:subjects).length)
    assert_equal(@subject_1.id,assigns(:subjects)[0].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
end
