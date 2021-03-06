require File.dirname(__FILE__) + '/../test_helper'

class QuizTest < Test::Unit::TestCase
  fixtures OrderedTables

  def test_address_active?
    quiz = Quiz.find( quizzes(:quiz_1).id )
    assert_equal( true, quiz.address_active?( '0.0.0.0' ) )
    assert_equal( false, quiz.address_active?( '127.0.0.12' ) )
  end

  def test_user_completed?
    quiz = Quiz.find( quizzes(:quiz_3).id )
    assert_equal( true, quiz.user_completed?( users(:peter_user).id ) )
    assert_equal( false, quiz.user_completed?( users(:sleepy_user).id ) )
    assert_equal( false, quiz.user_completed?( users(:admin_user).id ) )
  end

  def test_quiz_attempt_for_user
    quiz = Quiz.find( quizzes(:quiz_2).id )
    assert_equal( quiz_attempts(:qa_2).id, quiz.quiz_attempt_for_user( users(:peter_user).id, '12.23.34.45' ).id )
    assert_equal( 0, quiz.quiz_attempt_for_user( users(:admin_user).id, '12.23.34.45'  ).quiz_responses[0].answers.length )
    assert_equal( true, quiz.quiz_attempt_for_user( users(:admin_user).id, '12.23.34.45' ).quiz_responses[0].input.nil? )
  end

  def test_completed_attempts
    quiz = Quiz.find( quizzes(:quiz_2).id )
    assert_equal( 3, quiz.completed_attempts? )
  end

  def test_active_attempts
    quiz = Quiz.find( quizzes(:quiz_3).id )
    assert_equal( 1, quiz.active_attempts? )
    assert_equal( 0, Quiz.find(quizzes(:quiz_2).id).active_attempts? )
  end

end
