require File.dirname(__FILE__) + '/../test_helper'
require 'quiz_attempt'

class QuizAttempt < ActiveRecord::Base
  attr_accessor :time
  def now; @time; end
end

class QuizAttemptTest < Test::Unit::TestCase
  fixtures OrderedTables

  # PD
  def test_basic_create
    quiz_attempt = QuizAttempt.create( :start_time => Time.now,
                                       :quiz_id => quizzes(:quiz_1).id,
                                       :user_id => users(:peter_user).id )
    assert_equal(2, quiz_attempt.quiz_responses.count )
    assert_equal(1, quiz_attempt.quiz_responses[0].position )
    assert_equal(2, quiz_attempt.quiz_responses[1].position )
    assert_equal(questions(:q1).id, quiz_attempt.quiz_responses[0].question_id )
    assert_equal(questions(:q4).id, quiz_attempt.quiz_responses[1].question_id )
  end

  def test_next_response_and_completed?
    quiz_attempt = QuizAttempt.create( :start_time => Time.now,
                                       :quiz_id => quizzes(:quiz_1).id,
                                       :user_id => users(:peter_user).id )
    assert_equal(2, quiz_attempt.quiz_responses.count )
    assert_equal(1, quiz_attempt.quiz_responses[0].position )
    assert_equal(2, quiz_attempt.quiz_responses[1].position )
    assert_equal(questions(:q1).id, quiz_attempt.quiz_responses[0].question_id )
    assert_equal(questions(:q4).id, quiz_attempt.quiz_responses[1].question_id )

    quiz_attempt.reload
    qr = quiz_attempt.next_response
    assert_not_nil(qr)
    assert_equal(false, quiz_attempt.completed? )
    assert_equal(questions(:q1).id, qr.question_id )
    qr.completed = true
    qr.save!

    quiz_attempt.reload
    qr = quiz_attempt.next_response
    assert_not_nil(qr)
    assert_equal(false, quiz_attempt.completed? )
    assert_equal(questions(:q4).id, qr.question_id )
    qr.completed = true
    qr.save!

    quiz_attempt.reload
    qr = quiz_attempt.next_response
    assert_nil(qr)
    assert_equal(false, quiz_attempt.completed? )

    quiz_attempt.complete
    quiz_attempt.reload
    assert_equal(true, quiz_attempt.completed? )
  end

  # ~PD

  def test_incorrect_answers_multichoice_with_no_answers_selected
    quiz_attempt = QuizAttempt.find( quiz_attempts(:qa_2).id )
    assert_equal( 2, quiz_attempt.incorrect_answers.length )
    assert_equal( 3, quiz_attempt.quiz_responses.count )
    assert_equal( ["1", "2"], quiz_attempt.incorrect_answers )
  end

  def test_incorrect_answers_returns_correct_qn_numbers
    quiz_attempt = QuizAttempt.find( quiz_attempts(:qa_1).id )
    quiz_response = QuizResponse.find( quiz_responses(:qr_1).id )
    assert_equal( 1, quiz_attempt.incorrect_answers.length )
    assert_equal( 13, quiz_response.answers[0].id )
    assert_equal( ["3"], quiz_attempt.incorrect_answers )
  end

  def test_time_up_true
    quiz_attempt = QuizAttempt.new
    quiz_attempt.quiz_id = Quiz.find( quizzes(:quiz_1).id ).id
    quiz_attempt.start_time = '2005-11-7 01:00:00'
    quiz_attempt.user_id = 1
    assert_equal( 10, quiz_attempt.quiz.duration )
    quiz_attempt.time = Time.local(*ParseDate.parsedate('2005-11-7 01:10:10'))
    assert_equal( true, quiz_attempt.time_up? )
  end

  def test_time_up_false
    quiz_attempt = QuizAttempt.new
    quiz_attempt.quiz_id = Quiz.find( quizzes(:quiz_1).id ).id
    quiz_attempt.start_time = '2005-11-7 01:00:00'
    quiz_attempt.user_id = 1
    assert_equal( 10, quiz_attempt.quiz.duration )
    quiz_attempt.time = Time.local(*ParseDate.parsedate('2005-11-7 01:00:01'))
    assert_equal( false, quiz_attempt.time_up? )
  end

  def test_time_up_exact_time
    quiz_attempt = QuizAttempt.new
    quiz_attempt.quiz_id = Quiz.find( quizzes(:quiz_1).id ).id
    quiz_attempt.start_time = '2005-11-7 01:00:00'
    quiz_attempt.user_id = 1
    assert_equal( 10, quiz_attempt.quiz.duration )
    quiz_attempt.time = Time.local(*ParseDate.parsedate('2005-11-7 01:10:00'))
    assert_equal( false, quiz_attempt.time_up? )
  end

  def test_time_up_exact_timeplusone
    quiz_attempt = QuizAttempt.new
    quiz_attempt.quiz_id = Quiz.find( quizzes(:quiz_1).id ).id
    quiz_attempt.start_time = '2005-11-7 01:00:00'
    quiz_attempt.user_id = 1
    assert_equal( 10, quiz_attempt.quiz.duration )
    quiz_attempt.time = Time.local(*ParseDate.parsedate('2005-11-7 01:10:01'))
    assert_equal( true, quiz_attempt.time_up? )
  end
end
