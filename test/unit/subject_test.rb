require File.dirname(__FILE__) + '/../test_helper'

class SubjectTest < Test::Unit::TestCase
  fixtures OrderedTables

  def test_teachers
    subject = Subject.find( subjects(:subject_1).id )
    assert_equal( 1, subject.teachers.size )
    assert_equal( users(:lecturer_user).id, subject.teachers[0].id )
  end

  def test_demonstrators
    subject = Subject.find( subjects(:subject_2).id )
    assert_equal( users(:mr_fancy_pants_user).id, subject.demonstrators[0].id )
  end

  def test_students
    num_students = 3
    first_user_name = 'MrFancyPants'
    subject = Subject.find( subjects(:subject_2).id )
    assert_equal( num_students, subject.students.size )
    assert_equal( first_user_name, subject.students[0].name )
  end

  def test_find_all_sorted
    subjects = Subject.find_all_sorted
    assert_equal( 3, subjects.length )
    assert_equal( subjects(:subject_2).id, subjects[0].id )
    assert_equal( subjects(:subject_1).id, subjects[1].id )
    assert_equal( @subject_3.id, subjects[2].id )
  end
end
