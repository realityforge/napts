require File.dirname(__FILE__) + '/../test_helper'

class SubjectTest < Test::Unit::TestCase
  fixtures OrderedTables

  def test_teachers
    subject = Subject.find( @subject_1.id )
    assert_equal( 1, subject.teachers.size )
    assert_equal( "lect", subject.teachers[0].username )
    assert_equal( "4", subject.teachers[0].user_id )
  end
  
  def test_demonstrators
    subject = Subject.find( @subject_2.id )
    assert_equal( "Stan Driver", subject.demonstrators[0].name )
    assert_not_equal( "1", subject.demonstrators[0].user_id )
  end
  
end
