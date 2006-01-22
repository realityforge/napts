require File.dirname(__FILE__) + '/../test_helper'
require 'login_controller'

module ActionController #:nodoc:
  class TestRequest < AbstractRequest #:nodoc:
    def reset_session
      @session.delete
    end
  end
end

# Re-raise errors caught by the controller.
class LoginController; def rescue_action(e) raise e end; end

class LoginControllerTest < Test::Unit::TestCase
  fixtures OrderedTables
  
  def setup
    @controller = LoginController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_login_get
    get(:login, {}, {:data => 'blah'})
    assert_response(:success)
    assert_template('login')
    assert_valid_markup
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
    assert_nil(session[:data])
  end

  def test_login_post_with_invalid_user
    post(:login, {:username => 'peter', :password => 'bad_password', :type => 'Student'}, {:data => 'blah'})
    assert_redirected_to(:action => 'login')
    assert_nil(session[:data])
    assert_equal('Invalid user or password',flash[:alert])
    assert_nil(flash[:notice])
    assert_nil(session[:data])
  end

  def test_login_post_with_invalid_role
    post(:login, {:username => 'peter', :password => 'peter', :type => 'Administrator'}, {:data => 'blah'})
    assert_redirected_to(:action => 'login')
    assert_nil(session[:data])
    assert_equal('Access Denied',flash[:alert])
    assert_nil(flash[:notice])
    assert_nil(session[:data])
  end

  def test_login_post_success
    post(:login, {:username => 'peter', :password => 'peter', :type => 'Student'}, {:data => 'blah'})
    assert_redirected_to(:controller => 'welcome', :action => 'index')
    assert_equal(users(:peter_user).id,session[:user_id])
    assert_equal(:student,session[:role])
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
    assert_nil(session[:data])
  end

  def test_logout
    post(:logout, {}, {:user_id => 1})
    assert_redirected_to(:action => 'login')
    assert_nil(session[:user_id])
    assert_nil(flash[:alert])
    assert_equal('Logged out',flash[:notice])
  end
end
