class Computer < ActiveRecord::Base
  validates_length_of( :ip_address, :maximum => 16 )
  belongs_to( :room )
  validates_associated( :room )
  validates_presence_of( :room )
  validates_presence_of( :ip_address )
end
