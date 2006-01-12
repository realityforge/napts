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
    @id = @quiz_attempt_temp.id
    post( :restart, {:username => "peter"}, {:user_id => @mr_fancy_pants_user.id, :role => "Demonstrator"} )
    assert_equal( @quiz_attempt_temp, assigns(:quiz_attempt) )  
    assert_response( :redirect )
    assert_raise(ActiveRecord::RecordNotFound){QuizAttempt.find(@id)}
  end
  
  def test_show_get_questions_left
    start_quiz
    get( :show, { :quiz_attempt_id => assigns(:quiz_attempt).id, :quiz_response_position => 1 },
        {:user_id => @peter_user.id, :role => "Student"} )
    assert_equal( 1, assigns(:quiz_response).position )
    assert_response( :success )
    assert_template( 'show' )
  end
  
  
  def test_show_answer_multi_choice_question
    @quiz_attempt = QuizAttempt.create( :start_time => Time.now, 
                                        :quiz_id => @quiz_1.id, 
					:user_id => @peter_user.id )
    @quiz_response = QuizResponse.create( :created_at => Time.now, 
                             :question_id => @quiz_attempt.quiz.quiz_items[0].question_id,
	         	     :position => 1,
			     :quiz_attempt_id => @quiz_attempt.id )
			     
    post( :show, {:quiz_attempt_id => @quiz_attempt.id, 
                  :quiz_response_position => @quiz_response.position,
                  :answers => [ @q1_a1.id, @q1_a2.id ]},
		 {:user_id => @peter_user.id, :role => "Student"} )

    assert_nil( flash[:alert] )
    assert_equal( 1, @quiz_response.question.question_type )
    assert_equal( @q1_a1.id, @quiz_response.answers[0].id )
    assert_redirected_to( :action => 'show', 
                          :quiz_attempt_id => @quiz_attempt.id,
                          :quiz_response_position => 2 )
  end
  
  def test_show_no_answer_single_question
    @quiz_attempt = QuizAttempt.create( :start_time => Time.now, 
                                        :quiz_id => @quiz_1.id, 
					:user_id => @peter_user.id )
    @quiz_response = QuizResponse.create( :created_at => Time.now, 
                             :question_id => @quiz_attempt.quiz.quiz_items[1].question_id,
	         	     :position => 2,
			     :quiz_attempt_id => @quiz_attempt.id )
     post( :show, {:quiz_attempt_id => @quiz_attempt.id, 
                  :quiz_response_position => @quiz_response.position},
		 {:user_id => @peter_user.id, :role => "Student"} )
     assert_equal( 2, @quiz_response.question.question_type )
     assert_equal( "Must select an answer", flash[:alert] )
     assert_response( :success )
  end
  
  def test_show_last_question
    @quiz_attempt = QuizAttempt.create( :start_time => Time.now, 
                                        :quiz_id => @quiz_2.id, 
					:user_id => @peter_user.id )
    for quiz_item in @quiz.quiz_items
      if quiz_item.is_on_test
        @quiz_response = QuizResponse.create( :created_at => Time.now, 
                             :question_id => quiz_item.question_id,
	         	     :position => quiz_item.position,
			     :quiz_attempt_id => @quiz_attempt.id )
      end
    end

    get( :show, {:quiz_attempt_id => @quiz_attempt.id, 
                  :quiz_response_position => @quiz_response.position},
		 {:user_id => @peter_user.id, :role => "Student"} )
    assert_redirected_to( :action => 'end_quiz',
                          :quiz_attempt_id => @quiz_attempt.id,
			  :out_of_time => false )
  end
end
