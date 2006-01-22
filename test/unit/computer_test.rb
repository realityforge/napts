require File.dirname(__FILE__) + '/../test_helper'
require 'computer'

class Computer < ActiveRecord::Base
end

class ComputerTest < Test::Unit::TestCase
  fixtures OrderedTables
  
  def test_validate_format_correct
    computer = Computer.create( :room_id => 1, :ip_address => "123.123.123.123" )
    assert_valid( computer )
  end
  
  def test_validate_format_incorrect
    computer = Computer.create( :room_id => 1, :ip_address => "123.458" )
    assert_equal( false, computer.valid? )
  end
end
