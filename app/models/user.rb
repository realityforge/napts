require "digest/sha1"
class User < ActiveRecord::Base
  attr_accessor( :password )
  attr_accessible( :username, :password )
  validates_uniqueness_of( :username )
  validates_presence_of( :username, :password )
  
  def before_create
    self.hashed_password = User.hash_password( self.password )
  end
  
  def after_create
    @password = nil
  end
  
  def self.login( username, password )
    hashed_password = hash_password( password || "" )
    find( :first, 
          :conditions => ["username = ? and hashed_password =?", 
	                   username, hashed_password]
	)
  end
  
  def try_to_login
    User.login( self.username, self.password )
  end
  
  private
  def self.hash_password( password )
    Digest::SHA1.hexdigest(password)
  end
end
