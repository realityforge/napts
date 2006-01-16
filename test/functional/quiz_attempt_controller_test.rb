require File.dirname(__FILE__) + '/../test_helper'
require 'quiz_attempt_controller'

#Re-raise errors caught by the controller.
class QuizAttemptController; def rescue_action(e) raise e end; end

require 'quiz_attempt'

class QuizAttempt < ActiveRecord::Base
  cattr_accessor :time
  def now; @@time; end
end

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
    get(:restart, {}, {:user_id => @mr_fancy_pants_user.id, :role => :demonstrator} )
    assert_template( 'restart' )
    assert_valid_markup
  end
  
  def test_restart_post
    @quiz_attempt_temp = QuizAttempt.create(:start_time => Time.now, :quiz_id => @quiz_1.id, :user_id => @peter_user.id )
    @id = @quiz_attempt_temp.id
    post( :restart, {:username => "peter"}, {:user_id => @mr_fancy_pants_user.id, :role => :demonstrator} )
    assert_equal( @quiz_attempt_temp, assigns(:quiz_attempt) )  
    assert_response( :redirect )
    assert_raise(ActiveRecord::RecordNotFound){QuizAttempt.find(@id)}
  end
  
  def test_show_get_questions_left
    start_quiz
    get( :show, { :quiz_attempt_id => assigns(:quiz_attempt).id, :quiz_response_position => 1 },
        {:user_id => @peter_user.id, :role => :student} )
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
		 {:user_id => @peter_user.id, :role => :student} )

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
		 {:user_id => @peter_user.id, :role => :student} )
     assert_equal( 2, @quiz_response.question.question_type )
     assert_equal( "Must select an answer", flash[:alert] )
     assert_response( :success )
  end
  
  def test_show_last_question
    @quiz_attempt = QuizAttempt.create( :start_time => Time.now, 
                                        :quiz_id => @quiz_2.id, 
					:user_id => @peter_user.id )
    @count = 1
    for quiz_item in @quiz_2.quiz_items
      if quiz_item.is_on_test
        @quiz_attempt.quiz_responses.create( :created_at => Time.now,
	                                    :question_id => quiz_item.question.id,
					    :position => @count, 
					    :quiz_attempt_id => @quiz_attempt.id )
	@count += @count
      end
    end
    get( :show, {:quiz_attempt_id => @quiz_attempt.id, 
                  :quiz_response_position => 4 },
		 {:user_id => @peter_user.id, :role => :student} )
    assert_redirected_to( :action => 'end_quiz',
                          :quiz_attempt_id => @quiz_attempt.id,
			  :out_of_time => false )
  end
  
  def test_show_get_out_of_time
    @quiz_attempt = QuizAttempt.create( :start_time => '2005-11-7 12:00:00', 
                                        :quiz_id => @quiz_2.id, 
					:user_id => @peter_user.id )
    @count = 1
    for quiz_item in @quiz_2.quiz_items
      if quiz_item.is_on_test
        @quiz_attempt.quiz_responses.create( :created_at => Time.now,
	                                    :question_id => quiz_item.question.id,
					    :position => @count, 
					    :quiz_attempt_id => @quiz_attempt.id )
	@count += @count
      end
    end
    @quiz_attempt.time = Time.local(*ParseDate.parsedate('2005-11-7 12:20:10'))
    get( :show, {:quiz_attempt_id => @quiz_attempt.id,
                 :quiz_response_position => 1},
		 {:user_id => @peter_user.id, :role => :student } )
    assert_equal( 3, @quiz_attempt.quiz_responses.size )
    assert_equal( 15, @quiz_attempt.quiz.duration )
    assert_equal( true, @quiz_attempt.time_up? )
    assert_redirected_to( :action => 'end_quiz', 
                          :quiz_attempt_id => @quiz_attempt.id,
			  :out_of_time => true )
  end
  
  def test_end_quiz_out_of_time
    @quiz_attempt = QuizAttempt.create( :start_time => Time.now, 
                                        :quiz_id => @quiz_2.id, 
					:user_id => @peter_user.id )
  
    get( :end_quiz,
        {:quiz_attempt_id => @quiz_attempt.id, :out_of_time => true },
        {:user_id => @peter_user.id, :role => :student} )

    assert_equal( "Sorry, your time is up", flash[:alert] )
    assert_not_nil( assigns(:quiz_attempt).end_time )
    assert_redirected_to( :action => 'results', :quiz_attempt_id => @quiz_attempt.id )
  end

  def test_end_quiz_not_out_of_time
    @quiz_attempt = QuizAttempt.create( :start_time => Time.now, 
                                        :quiz_id => @quiz_2.id, 
					:user_id => @peter_user.id )
  
    get( :end_quiz,
        {:quiz_attempt_id => @quiz_attempt.id, :out_of_time => false },
        {:user_id => @peter_user.id, :role => :student} )
    assert_nil( flash[:alert] )
    assert_not_nil( assigns(:quiz_attempt).end_time )
    assert_redirected_to( :action => 'results', :quiz_attempt_id => @quiz_attempt.id )
  end
  
  def test_results
    @quiz_attempt = QuizAttempt.find( @qa_2.id )
    get( :results, {:quiz_attempt_id => @quiz_attempt.id }, {:user_id => @peter_user.id, :role => :student } )
    assert_equal( ["1", "2"]  , assigns(:results) )
    assert_valid_markup
  end
  
end
