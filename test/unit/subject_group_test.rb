require File.dirname(__FILE__) + '/../test_helper'

class SubjectGroupTest < Test::Unit::TestCase
  fixtures OrderedTables

  def test_find_all_sorted
    groups = SubjectGroup.find_all_sorted
    assert_equal(3, groups.size)
    assert_equal(subject_groups(:sg_3).id,groups[0].id)
    assert_equal(subject_groups(:sg_1).id,groups[1].id)
    assert_equal(subject_groups(:sg_2).id,groups[2].id)
  end
end
