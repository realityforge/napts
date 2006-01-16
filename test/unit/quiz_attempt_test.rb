require File.dirname(__FILE__) + '/../test_helper'
require 'quiz_attempt'

class QuizAttempt < ActiveRecord::Base
  attr_accessor :time
  def now; @time; end
end

class QuizAttemptTest < Test::Unit::TestCase
  fixtures OrderedTables

  def test_incorrect_answers_multichoice_with_no_answers_selected
    quiz_attempt = QuizAttempt.find( @qa_2.id )
    assert_equal( 2, quiz_attempt.incorrect_answers.length )
    assert_equal( 3, quiz_attempt.quiz_responses.count )
    assert_equal( ["1", "2"], quiz_attempt.incorrect_answers )
  end
  
  def test_incorrect_answers_returns_correct_qn_numbers
    quiz_attempt = QuizAttempt.find( @qa_1.id )
    quiz_response = QuizResponse.find( @qr_4.id )
    assert_equal( 2, quiz_attempt.incorrect_answers.length )
    assert_equal( 13, quiz_response.answers[0].id )
    assert_equal( ["2", "3"], quiz_attempt.incorrect_answers )
  end
  
  def test_time_up_true
    quiz_attempt = QuizAttempt.new
    quiz_attempt.quiz_id = Quiz.find( @quiz_1.id ).id
    quiz_attempt.start_time = '2005-11-7 01:00:00'
    quiz_attempt.user_id = 1
    assert_equal( 10, quiz_attempt.quiz.duration )
    quiz_attempt.time = Time.local(*ParseDate.parsedate('2005-11-7 01:10:10'))
    assert_equal( true, quiz_attempt.time_up? )
  end
  
  def test_time_up_false
    quiz_attempt = QuizAttempt.new
    quiz_attempt.quiz_id = Quiz.find( @quiz_1.id ).id
    quiz_attempt.start_time = '2005-11-7 01:00:00'
    quiz_attempt.user_id = 1
    assert_equal( 10, quiz_attempt.quiz.duration )
    quiz_attempt.time = Time.local(*ParseDate.parsedate('2005-11-7 01:00:01'))
    assert_equal( false, quiz_attempt.time_up? )
  end
  
  def test_time_up_exact_time
    quiz_attempt = QuizAttempt.new
    quiz_attempt.quiz_id = Quiz.find( @quiz_1.id ).id
    quiz_attempt.start_time = '2005-11-7 01:00:00'
    quiz_attempt.user_id = 1
    assert_equal( 10, quiz_attempt.quiz.duration )
    quiz_attempt.time = Time.local(*ParseDate.parsedate('2005-11-7 01:10:00'))
    assert_equal( false, quiz_attempt.time_up? )
  end
  
  def test_time_up_exact_timeplusone
    quiz_attempt = QuizAttempt.new
    quiz_attempt.quiz_id = Quiz.find( @quiz_1.id ).id
    quiz_attempt.start_time = '2005-11-7 01:00:00'
    quiz_attempt.user_id = 1
    assert_equal( 10, quiz_attempt.quiz.duration )
    quiz_attempt.time = Time.local(*ParseDate.parsedate('2005-11-7 01:10:01'))
    assert_equal( true, quiz_attempt.time_up? )
  end
  
  def test_get_response
    @quiz = Quiz.find( @quiz_1.id )
    @quiz_attempt = QuizAttempt.new
    @quiz_attempt.quiz_id = @quiz.id
    @quiz_attempt.start_time = '2005-11-7 01:00:00'
    @quiz_attempt.user_id = 1
    count = 1
    for quiz_item in @quiz.quiz_items
      if quiz_item.is_on_test
        @quiz_attempt.quiz_responses.create( :created_at => Time.now,
	                                    :question_id => quiz_item.question.id,
					    :position => count, 
					    :quiz_attempt_id => @quiz_attempt.id )
	count += count
      end
    end
    assert_equal( 1, @quiz_attempt.get_response(1).position )
    assert_equal( 2, @quiz_attempt.get_response(2).position ) 
    assert_equal( nil, @quiz_attempt.get_response(3) )
  end
  
  def test_get_response_2
     @quiz = Quiz.find( @quiz_2.id )
    @quiz_attempt = QuizAttempt.create( :quiz_id => @quiz.id,
                                        :start_time => '2005-11-7 01:00:00',
                                        :user_id => 1 )
    @count = 1
    for quiz_item in @quiz.quiz_items
      if quiz_item.is_on_test
        @quiz_attempt.quiz_responses.create( :created_at => Time.now,
	                                    :question_id => quiz_item.question.id,
					    :position => @count, 
					    :quiz_attempt_id => @quiz_attempt.id )
	@count += @count
      end
    end
    assert_equal( 1, @quiz_attempt.get_response(1).position )
    assert_equal( 2, @quiz_attempt.get_response(2).position )
    assert_equal( 3, @quiz_attempt.get_response(3).position )
    assert_equal( nil, @quiz_attempt.get_response(4) )
    @qi = QuizItem.create( :quiz_id => @quiz_2.id, :position => 4, :question_id => 2, :is_on_test => true )
    @quiz_attempt.quiz_responses.create( :created_at => Time.now,
	                                 :question_id => 2,
					 :position => @count, 
					 :quiz_attempt_id => @quiz_attempt.id )
    assert_equal( 4, @quiz_attempt.get_response(4).position )
  end
 
  
end
