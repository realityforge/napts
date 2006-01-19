require File.dirname(__FILE__) + '/../test_helper'

class SubjectTest < Test::Unit::TestCase
  fixtures OrderedTables

  def test_teachers
    subject = Subject.find( @subject_1.id )
    assert_equal( 1, subject.teachers.size )
    assert_equal( @lecturer_user.id, subject.teachers[0].id )
  end
  
  def test_demonstrators
    subject = Subject.find( @subject_2.id )
    assert_equal( @mr_fancy_pants_user.id, subject.demonstrators[0].id )
  end
  
end
