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

  def test_subjects
    group = SubjectGroup.find( subject_groups(:sg_1).id )
    assert_equal(1, group.subjects.size)
    assert_equal(subjects(:subject_1).id, group.subjects[0].id)
  end

  def test_questions
    group = SubjectGroup.find( subject_groups(:sg_1).id )
    assert_equal(4, group.questions.size)
    assert_equal(questions(:q1).id, group.questions[0].id)
    assert_equal(questions(:q2).id, group.questions[1].id)
    assert_equal(questions(:q3).id, group.questions[2].id)
    assert_equal(questions(:q10).id, group.questions[3].id)
  end

  def test_resources
    group = SubjectGroup.find( subject_groups(:sg_1).id )
    assert_equal(1, group.resources.size)
    assert_equal(resources(:resource_1).id, group.resources[0].id)
  end
end
