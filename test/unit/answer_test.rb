require File.dirname(__FILE__) + '/../test_helper'

class AnswerTest < Test::Unit::TestCase
  fixtures :answers

  def setup
    @answer = Answer.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Answer,  @answer
  end
end
