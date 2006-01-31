class Resource < ActiveRecord::Base
  has_one( :resource_data, :dependent => true )
  validates_presence_of( :mime_type, :name )
end
