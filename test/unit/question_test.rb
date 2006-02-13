require File.dirname(__FILE__) + '/../test_helper'

class QuestionTest < Test::Unit::TestCase
  fixtures OrderedTables

  def test_has_resource
    assert_equal(true, questions(:q1).has_resource?)
    assert_equal(false, questions(:q2).has_resource?)
  end
end
