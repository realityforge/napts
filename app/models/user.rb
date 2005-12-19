require "digest/sha1"

class User < ActiveRecord::Base
  has_many( :quiz_attempts )
  attr_accessor( :password )
  attr_accessible( :username, :password, :name )
  validates_uniqueness_of( :username )
  validates_presence_of( :username, :password )
  
  def before_create
    self.hashed_password = User.hash_password( self.password )
  end
  
  def after_create
    @password = nil
  end
  
  def self.authenticate(username, password)
    find_first( [ 'username = ? AND hashed_password = ?', username, User.hash_password(password) ] )
  end
  
  private
  def self.hash_password( password )
    Digest::SHA1.hexdigest(password)
  end
end
