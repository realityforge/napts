require File.dirname(__FILE__) + '/../test_helper'

class QuizTest < Test::Unit::TestCase
  fixtures :quizzes

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Quiz, quizzes(:first)
  end
end
