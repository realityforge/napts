require File.dirname(__FILE__) + '/../test_helper'

class QuestionTest < Test::Unit::TestCase
  fixtures :questions

  def setup
    @question = Question.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Question,  @question
  end
end
