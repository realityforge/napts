require File.dirname(__FILE__) + '/../test_helper'

class QuizAttemptTest < Test::Unit::TestCase
  fixtures OrderedTables

  def test_score_length
    quiz_attempt = QuizAttempt.find( @qa_2.id )
    assert_equal( 2, quiz_attempt.score.length )
  end
  
  def test_score_returns_correct_qn_numbers
    quiz_attempt = QuizAttempt.find( @qa_1.id )
    assert_equal( 2, quiz_attempt.score.length )
    assert_equal( 13, answers_quiz_responses(:a1_qr4).answer_id.to_i )
  end
end
