require File.dirname(__FILE__) + '/../test_helper'
require 'auth_helper'

class AuthHelperObject
  include AuthHelper
end

class FakeUser
  def initialize(administrator, educator, demonstrator)
    @administrator = administrator
    @educator = educator
    @demonstrator = demonstrator
  end
  def administrator?; @administrator; end
  def educator?; @educator; end
  def demonstrator?; @demonstrator; end
end

class AuthHelperTest < Test::Unit::TestCase
  def test_to_role
    h = AuthHelperObject.new
    assert_equal(:administrator, h.to_role("Administrator"))
    assert_equal(:educator, h.to_role("Educator"))
    assert_equal(:demonstrator, h.to_role("Demonstrator"))
    assert_equal(:student, h.to_role("Student"))
    assert_nil(h.to_role("somethingelse"))
  end

  def test_get_verified_role
    h = AuthHelperObject.new
    assert_equal(:administrator, h.get_verified_role(FakeUser.new(true,true,true),"Administrator"))
    assert_nil( h.get_verified_role(FakeUser.new(false,false,false),"Administrator"))
    assert_equal(:educator, h.get_verified_role(FakeUser.new(true,true,true),"Educator"))
    assert_nil( h.get_verified_role(FakeUser.new(false,false,false),"Educator"))
    assert_equal(:demonstrator, h.get_verified_role(FakeUser.new(true,true,true),"Demonstrator"))
    assert_nil( h.get_verified_role(FakeUser.new(false,false,false),"Demonstrator"))
    assert_equal(:student, h.get_verified_role(FakeUser.new(true,true,true),"Student"))
    assert_nil( h.get_verified_role(FakeUser.new(false,false,false),"Other"))
  end
end
