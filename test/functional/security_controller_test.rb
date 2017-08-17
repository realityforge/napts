require File.dirname(__FILE__) + '/../test_helper'
require 'security_controller'

# Re-raise errors caught by the controller.
class SecurityController; def rescue_action(e) raise e end; end

class SecurityControllerTest < Test::Unit::TestCase
  fixtures OrderedTables

  def setup
    @controller = SecurityController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_access_denied_get
    get(:access_denied, {}, {:user_id => users(:peter_user).id, :role => :student})
    assert_response(:success)
    assert_template('access_denied')
    assert_valid_markup
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
end
