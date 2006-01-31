class ResourceData < ActiveRecord::Base
  belongs_to( :resource )
  validates_associated( :resource )
  validates_presence_of( :data )
end
