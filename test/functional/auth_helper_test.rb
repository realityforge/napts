require File.dirname(__FILE__) + '/../test_helper'
require 'auth_helper'

class AuthHelperObject
  include AuthHelper
end

class FakeUser
  def initialize(administrator, teacher, demonstrator)
    @administrator = administrator
    @teacher = teacher
    @demonstrator = demonstrator
  end
  def administrator?; @administrator; end
  def teacher?; @teacher; end
  def demonstrator?; @demonstrator; end
  def teaches?(subject_id); 1 == subject_id; end
  def demonstrator_for?(subject_id); 1 == subject_id; end
end

class AuthHelperTest < Test::Unit::TestCase
  def test_to_role
    h = AuthHelperObject.new
    assert_equal(:administrator, h.to_role("Administrator"))
    assert_equal(:teacher, h.to_role("Teacher"))
    assert_equal(:demonstrator, h.to_role("Demonstrator"))
    assert_equal(:student, h.to_role("Student"))
    assert_nil(h.to_role("somethingelse"))
  end

  def test_get_verified_role
    h = AuthHelperObject.new
    assert_equal(:administrator, h.get_verified_role(FakeUser.new(true,true,true),"Administrator",nil))
    assert_nil( h.get_verified_role(FakeUser.new(false,false,false),"Administrator",nil))
    assert_equal(:teacher, h.get_verified_role(FakeUser.new(true,true,true),"Teacher",1))
    assert_nil( h.get_verified_role(FakeUser.new(true,true,true),"Teacher",0))
    assert_nil( h.get_verified_role(FakeUser.new(false,false,false),"Teacher",0))
    assert_equal(:demonstrator, h.get_verified_role(FakeUser.new(true,true,true),"Demonstrator",1))
    assert_nil( h.get_verified_role(FakeUser.new(true,true,true),"Demonstrator",0))
    assert_nil( h.get_verified_role(FakeUser.new(false,false,false),"Demonstrator",0))
    assert_equal(:student, h.get_verified_role(FakeUser.new(true,true,true),"Student",nil))
    assert_nil( h.get_verified_role(FakeUser.new(false,false,false),"Other",nil))
  end

  def test_requires_subject?
    h = AuthHelperObject.new
    assert_equal(false, h.requires_subject?(:administrator))
    assert_equal(true, h.requires_subject?(:teacher))
    assert_equal(true, h.requires_subject?(:demonstrator))
    assert_equal(false, h.requires_subject?(:student))
  end
end
