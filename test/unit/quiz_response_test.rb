require File.dirname(__FILE__) + '/../test_helper'

class QuizResponseTest < Test::Unit::TestCase
  fixtures OrderedTables

  def test_answers
    quiz_response = QuizResponse.find(quiz_responses(:qr_1).id)
    assert_equal(1, quiz_response.answers.size)
    assert_equal(answers(:q4_a1).id, quiz_response.answers[0].id)
  end

  def test_correct
    quiz_response = QuizResponse.find( quiz_responses(:qr_3).id)
    assert_equal( false, quiz_response.correct? )
    assert_equal( true, QuizResponse.find(quiz_responses(:qr_1).id).correct? )
    assert_equal( false, QuizResponse.find(quiz_responses(:qr_4).id).correct? )
    assert_equal( true, QuizResponse.find(quiz_responses(:qr_2).id).correct? )
  end

  def test_correct_corrected_at
    question = Question.new(:content => "X",
                            :question_type => 2,
		            :subject_group_id => 1,
		            :corrected_at => (Time.now - 10) )
    quiz_response = QuizResponse.new(:updated_at => Time.now,
                                     :quiz_attempt_id => 1,
				     :question => question,
				     :position => 3,
				     :completed => true)
    assert_equal(true, quiz_response.correct?)
  end
end
