require File.dirname(__FILE__) + '/../test_helper'
require 'computer'

class Computer < ActiveRecord::Base
end

class ComputerTest < Test::Unit::TestCase
  fixtures OrderedTables

  def test_validate_format_correct
    assert_valid(Computer.create(:room_id => 1, :ip_address => "123.123.123.123"))
  end

  def test_validate_format_incorrect
    assert_equal(false, Computer.create(:room_id => 1, :ip_address => "123.458").valid?)
  end
end
