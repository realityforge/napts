require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures OrderedTables

  def test_demonstrates_for
    user = users(:peter_user)
    assert_equal(2 , user.demonstrates_for.size)
    assert_equal(subjects(:subject_1).id, user.demonstrates_for[0].id)
    assert_equal(subjects(:subject_3).id, user.demonstrates_for[1].id)
  end

  def test_teaches
    user = users(:lecturer_user)
    assert_equal(2, user.teaches.size)
    assert_equal(subjects(:subject_2).id, user.teaches[0].id)
    assert_equal(subjects(:subject_1).id, user.teaches[1].id)
  end

  def test_enrolled_in
    user = users(:peter_user)
    assert_equal(2, user.enrolled_in.size)
    assert_equal(subjects(:subject_2).id, user.enrolled_in[0].id)
    assert_equal(subjects(:subject_1).id, user.enrolled_in[1].id)
  end

  def test_teacher?
    assert_equal(true , users(:lecturer_user).teacher?)
    assert_equal(false, users(:mr_fancy_pants_user).teacher?)
  end

  def test_demonstrator?
    assert_equal(true, users(:peter_user).demonstrator?)
    assert_equal(false, users(:admin_user).demonstrator?)
  end

  def test_demonstrator_for?
    assert_equal(true, users(:peter_user).demonstrator_for?(subjects(:subject_1).id))
    assert_equal(false, users(:mr_fancy_pants_user).demonstrator_for?(subjects(:subject_1).id))
  end

  def test_teacher_for?
    assert_equal(true, users(:admin_user).teaches?(subjects(:subject_3).id))
    assert_equal(false, users(:peter_user).teaches?(subjects(:subject_2).id))
  end

  def test_authenticate_failed
    user = User.authenticate(users(:peter_user).name,'')
    assert_equal(true, user.nil?)
  end

  def test_authenticate_find_existing
    user = User.authenticate(users(:peter_user).name,users(:peter_user).name)
    assert_equal(false, user.nil?)
    assert_equal(users(:peter_user).id, user.id)
  end

  def test_authenticate_create_new
    count = User.count
    user = User.authenticate('billy', 'billy')
    assert_equal(count + 1, User.count)
    assert_equal(false, user.nil?)
    assert_equal('billy',user.name)
    assert_equal(false,user.administrator?)
  end
end
