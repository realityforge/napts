require "digest/sha1"

class User < ActiveRecord::Base
  has_many( :quiz_attempts, :order => "start_time DESC" )
  has_and_belongs_to_many( :demonstrates_for, :class_name => "Subject", :order => "code", :join_table => "demonstrators" )
  has_and_belongs_to_many( :educates_for, :class_name => "Subject", :order => "code", :join_table => "educators" )
  attr_accessor( :password )
  attr_accessible( :username, :password, :name )
  validates_uniqueness_of( :username )
  validates_presence_of( :username, :hashed_password )
  
  USER_ROLE = [ "Student", "Demonstrator", "Educator", "Administrator" ].freeze
  
  def before_create
    self.hashed_password = User.hash_password( self.password )
  end
  
  def after_create
    @password = nil
  end
  
  def self.authenticate(username, password)
    find_first( [ 'username = ? AND hashed_password = ?', username, User.hash_password(password) ] )
  end
    
  def demonstrator?
    self.demonstrates_for.size > 0
  end
  
   def educator?
    self.educates_for.size > 0
  end
  
  private
  def self.hash_password( password )
    Digest::SHA1.hexdigest(password)
  end
end
