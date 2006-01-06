require File.dirname(__FILE__) + '/../test_helper'

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
end
