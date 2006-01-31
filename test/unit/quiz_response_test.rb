require File.dirname(__FILE__) + '/../test_helper'

class QuizResponseTest < Test::Unit::TestCase
  fixtures OrderedTables

  def test_answers
    quiz_response = QuizResponse.find(quiz_responses(:qr_1).id)
    assert_equal(1, quiz_response.answers.size)
    assert_equal(answers(:q4_a1).id, quiz_response.answers[0].id)
  end
end
