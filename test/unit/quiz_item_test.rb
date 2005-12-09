require File.dirname(__FILE__) + '/../test_helper'

class QuizItemTest < Test::Unit::TestCase
  fixtures :quiz_items

  # Replace this with your real tests.
  def test_truth
    assert_kind_of QuizItem, quiz_items(:first)
  end
end
