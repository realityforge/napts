require File.dirname(__FILE__) + '/../test_helper'
require 'quiz_attempt'

class QuizAttemptTest < Test::Unit::TestCase
  fixtures OrderedTables

  def test_basic_create
    quiz_attempt = QuizAttempt.create( :created_at => Time.now,
                                       :quiz_id => quizzes(:quiz_1).id,
                                       :user_id => users(:peter_user).id )
    assert_equal(2, quiz_attempt.quiz_responses.count )
    assert_equal(1, quiz_attempt.quiz_responses[0].position )
    assert_equal(2, quiz_attempt.quiz_responses[1].position )
    assert_equal(questions(:q1).id, quiz_attempt.quiz_responses[0].question_id )
    assert_equal(questions(:q4).id, quiz_attempt.quiz_responses[1].question_id )
  end

  def test_next_response_and_completed?
    quiz_attempt = QuizAttempt.create( :created_at => Time.now,
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

  def test_incorrect_answers_multichoice_with_no_answers_selected
    quiz_attempt = quiz_attempts(:qa_2)
    assert_equal(2, quiz_attempt.incorrect_answers.length)
    assert_equal(3, quiz_attempt.quiz_responses.count)
    assert_equal([1, 2], quiz_attempt.incorrect_answers)
  end

  def test_incorrect_answers_returns_correct_qn_numbers
    quiz_attempt = quiz_attempts(:qa_1)
    assert_equal(1, quiz_attempt.incorrect_answers.length)
    assert_equal([3], quiz_attempt.incorrect_answers)
  end

  def test_time_up_true
    do_time_test('2005-11-7 01:00:00','2005-11-7 01:10:10',true)
  end

  def test_time_up_false
    do_time_test('2005-11-7 01:00:00','2005-11-7 01:00:01',false)
  end

  def test_time_up_exact_time
    do_time_test('2005-11-7 01:00:00','2005-11-7 01:10:00',false)
  end

  def test_time_up_exact_timeplusone
    do_time_test('2005-11-7 01:00:00','2005-11-7 01:10:01',true)
  end
  
  def test_calculate_score
    quiz_attempt = QuizAttempt.find( quiz_attempts(:qa_1).id )
    assert_equal( 3, quiz_attempt.quiz_responses.length )
    assert_nil( quiz_attempt.score )
    assert_equal( 2, quiz_attempt.calculate_score )
    assert_equal( 2, quiz_attempt.score )
    assert_equal([3], quiz_attempt.incorrect_answers )
  end

  private

  def do_time_test(start,now,expected)
    assert_equal(expected, gen_time(start).time_up?(Time.local(*ParseDate.parsedate(now))))
  end

  def gen_time(time)
    quiz_attempt = QuizAttempt.new
    quiz_attempt.quiz_id = quizzes(:quiz_1).id
    quiz_attempt.created_at = time
    quiz_attempt.user_id = users(:peter_user).id
    assert_equal(10, quiz_attempt.quiz.duration)
    quiz_attempt
  end
end
