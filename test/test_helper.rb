ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = true
  
  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false
  self.pre_loaded_fixtures = true
   
  # Add more helper methods to be used by all tests here...
  def start_quiz
    @user = User.find( users(:peter_user).id )
    get( :start_quiz, 
        {:quiz_id => quizzes(:quiz_1).id },
	{:user_id => @user.id, :role => :student} )
    assert_not_nil( assigns(:quiz_attempt) )
    assigns(:quiz_attempt).reload
    assert_equal( 2, assigns(:quiz_attempt).quiz_responses.length )
    assert_equal( 'peter', @user.name )
    assert_redirected_to( :action => 'show', 
                          :quiz_attempt_id => assigns(:quiz_attempt).id,
                          :quiz_response_position => 1 )
  end
end
