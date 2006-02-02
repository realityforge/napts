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
    assert_equal( quiz_attempts(:qa_2).id, quiz.quiz_attempt_for_user( users(:peter_user).id ).id )
    assert_equal( 0, quiz.quiz_attempt_for_user( users(:admin_user).id ).quiz_responses[0].answers.length )
    assert_equal( true, quiz.quiz_attempt_for_user( users(:admin_user).id ).quiz_responses[0].input.nil? )
  end

end
