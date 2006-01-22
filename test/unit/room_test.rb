require File.dirname(__FILE__) + '/../test_helper'

class RoomTest < Test::Unit::TestCase
  fixtures OrderedTables

  def test_addresses
    assert_equal("255.255.255.255\n12.13.14.15\n123.123.145.154", @room_1.addresses)
  end

  def test_addresses=
      room = Room.create!(:name => 'MyRoom')
    assert_equal("", room.addresses)
    room.addresses = "255.255.255.255\n12.13.14.15\n123.123.145.154"
    assert_nil(room.errors[:base])
    room.reload
    assert_equal("255.255.255.255\n12.13.14.15\n123.123.145.154", room.addresses)

    room.addresses = "255.x.145.154 123.4.5.6 1.2.3.4 21.12.12.a"
    room.reload
    assert_not_nil(room.errors[:base])
    assert_equal('The following ip addresses are badly formatted: 255.x.145.154 21.12.12.a',room.errors[:base])
  end
end
