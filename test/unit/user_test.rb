require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures OrderedTables

  def test_demonstrates_for
    user = User.find( users(:peter_user).id )
    assert_equal( 'peter', user.name )
    assert_equal( 2 , user.demonstrates_for.size )
    assert_equal( "1" , user.demonstrates_for[0].subject_id )
    assert_equal( "CSE21DB" , user.demonstrates_for[1].name )
  end

  def test_teaches
    user = User.find( users(:lecturer_user).id )
    assert_equal( 2, user.teaches.size )
    assert_equal( "2", user.teaches[0].subject_id )
    assert_equal( "1", user.teaches[1].subject_id )
  end

  def test_enrolled_in
    num_subjects = 2
    subject_id_1 = "2"
    subject_id_2 = "1"
    user = User.find( users(:peter_user).id )
    assert_equal( num_subjects, user.enrolled_in.size )
    assert_equal( subject_id_1, user.enrolled_in[0].subject_id )
    assert_equal( subject_id_2, user.enrolled_in[1].subject_id )
  end

  def test_teacher?
    assert_equal( true , User.find( users(:lecturer_user).id ).teacher? )
    assert_equal( false, User.find( users(:mr_fancy_pants_user).id  ).teacher? )
  end

  def test_demonstrator?
    assert_equal( true, User.find( users(:peter_user).id ).demonstrator? )
    assert_equal( false, User.find( users(:admin_user).id ).demonstrator? )
  end

  def test_demonstrator_for?
    assert_equal( true, User.find( users(:peter_user).id ).demonstrator_for?( 1 ) )
    assert_equal( false, User.find( users(:mr_fancy_pants_user).id).demonstrator_for?(1) )
  end

  def test_teacher_for?
    assert_equal( true, User.find(users(:admin_user).id).teaches?(subjects(:subject_3).id) )
    assert_equal( false, User.find(users(:peter_user).id).teaches?(subjects(:subject_2).id) )
  end
end
