class Computer < ActiveRecord::Base
  #need to write regular expression for validating ip address...
  #this one's just temporary
  AddressRegex = /^(\d{1,3}\.){3}\d{1,3}$/

  validates_format_of( :ip_address, :with => AddressRegex )
  validates_length_of( :ip_address, :maximum => 16 )
  belongs_to( :room )
  validates_associated( :room )
  validates_presence_of( :room )
  validates_presence_of( :ip_address )
  validates_uniqueness_of( :ip_address, :scope => :room_id )
end
