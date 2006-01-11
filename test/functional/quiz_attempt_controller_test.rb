require File.dirname(__FILE__) + '/../test_helper'
require 'quiz_attempt_controller'

#Re-raise errors caught by the controller.
class QuizAttemptController; def rescue_action(e) raise e end; end

class QuizAttemptControllerTest < Test::Unit::TestCase
  fixtures OrderedTables
  
  def setup
    @controller = QuizAttemptController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
  
  def test_start_quiz_creates_quiz_attempt
    get( :start_quiz, {:start_time => Time.now, :quiz_id => @quiz_1.id}, {:user_id =>  @peter_user.id, :role => "Student"})
    assert_equal( 2, assigns(:quiz_attempt).quiz_responses.length )
    assert_response( :redirect )
  end
  
  def test_restart_get
  get(:restart, {}, {:user_id => @mr_fancy_pants_user.id, :role => "Demonstrator"} )
    assert_template( 'restart' )
    assert_valid_markup
  end
  
  def test_restart_post
    @quiz_attempt_temp = QuizAttempt.create(:start_time => Time.now, :quiz_id => @quiz_1.id, :user_id => @peter_user.id )
    post( :restart, {:username => "peter"}, {:user_id => @mr_fancy_pants_user.id, :role => "Demonstrator"} )
    assert_equal( @quiz_attempt_temp, assigns(:quiz_attempt) )  
    assert_response( :redirect )
  end
end
