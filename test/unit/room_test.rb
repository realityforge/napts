require File.dirname(__FILE__) + '/../test_helper'

class RoomTest < Test::Unit::TestCase
  fixtures OrderedTables

  def test_find_all_sorted
    rooms = Room.find_all_sorted
    assert_equal(2, rooms.length)
    assert_equal(rooms(:room_1).id, rooms[0].id)
    assert_equal(rooms(:room_2).id, rooms[1].id)
  end

  def test_addresses
    assert_equal("12.13.14.15\n123.123.145.154\n255.255.255.255", rooms(:room_1).addresses)
  end

  def test_addresses=
      room = Room.create!(:name => 'MyRoom')
    assert_equal("", room.addresses)
    room.addresses = "255.255.255.255\n12.13.14.15\n123.123.145.154"
    room.save
    assert_nil(room.errors[:base])
    room = Room.find(room.id)
    assert_equal("12.13.14.15\n123.123.145.154\n255.255.255.255", room.addresses)

    room.addresses = "255.x.145.154 123.4.5.6 1.2.3.4 21.12.12.a"
    room.valid?
    assert_not_nil(room.errors[:base])
    assert_equal('The following ip addresses are badly formatted: 255.x.145.154 21.12.12.a',room.errors[:base])
  end
end
