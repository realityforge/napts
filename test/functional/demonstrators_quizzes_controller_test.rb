require File.dirname(__FILE__) + '/../test_helper'
require 'demonstrators/quizzes_controller'

#Re-raise errors caught by the controller.
class Demonstrators::QuizzesController; def rescue_action(e) raise e end; end

require 'quiz_attempt'

class Quizzes < ActiveRecord::Base
  cattr_accessor :time
  def now; @@time; end
end

class QuizzesControllerTest < Test::Unit::TestCase
  fixtures OrderedTables
  
  def setup
    @controller = Demonstrators::QuizzesController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
  
  def test_restart_get
    get(:restart, {}, {:user_id => @mr_fancy_pants_user.id, :role => :demonstrator, :subject_id => @subject_2.id} )
    assert_template( 'restart' )
    assert_valid_markup
  end
  
  def test_restart_post
    @quiz_attempt_temp = QuizAttempt.create(:start_time => Time.now, :quiz_id => @quiz_1.id, :user_id => @peter_user.id )
    @id = @quiz_attempt_temp.id
    post( :restart, 
          {:username => 'peter', :quiz_id => @quiz_1.id}, 
          {:user_id => @peter_user.id, :role => :demonstrator, :subject_id => @subject_1.id} )
    assert_equal( @quiz_attempt_temp, assigns(:quiz_attempt) )  
    assert_response( :redirect )
    assert_raise(ActiveRecord::RecordNotFound){QuizAttempt.find(@id)}
  end
  
end
