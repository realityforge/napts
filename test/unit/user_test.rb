require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures OrderedTables
   
  def test_demonstrates_for
    user = User.find( @peter_user.id )
    assert_equal( 'peter', user.username )
    assert_equal( 2 , user.demonstrates_for.size )
    assert_equal( "1" , user.demonstrates_for[0].subject_id )
    assert_equal( "CSE21DB" , user.demonstrates_for[1]. code )
  end
  
  def test_educates_for
    user = User.find( @lecturer_user.id )
    assert_equal( 2, user.educates_for.size )
    assert_equal( "2", user.educates_for[0].subject_id )
    assert_equal( "1", user.educates_for[1].subject_id )
  end
  
  def test_educator?
    assert_equal( true , User.find( @lecturer_user.id ).educator? )
    assert_equal( false, User.find( @mr_fancy_pants_user.id  ).educator? )
  end
  
  def test_demonstrator?
    assert_equal( true, User.find( @peter_user.id ).demonstrator? )
    assert_equal( false, User.find( @admin_user.id ).demonstrator? )
  end
  
end
