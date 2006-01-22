require "digest/sha1"

class User < ActiveRecord::Base
  has_many( :quiz_attempts, :order => 'start_time DESC', :dependent => true )
  has_and_belongs_to_many( :demonstrates_for, :class_name => 'Subject', :order => 'name', :join_table => 'demonstrators', :uniq => true )
  has_and_belongs_to_many( :teaches, :class_name => 'Subject', :order => 'name', :join_table => 'teachers', :uniq => true )
  attr_accessor( :password )
  attr_accessible( :name, :password )
  validates_uniqueness_of( :name )
  validates_presence_of( :username )
  validates_presence_of( :password, :on => :create )
  
  def before_create
    self.hashed_password = User.hash_password( self.password )
  end
  
  def after_create
    @password = nil
  end
  
  def self.authenticate(name, password)
    find_first( [ 'name = ? AND hashed_password = ?', name, User.hash_password(password) ] )
  end
    
  def demonstrator?
    self.demonstrates_for.size > 0
  end
  
  def demonstrator_for?( subject_id )
    for s in self.demonstrates_for
      return true if s.id == subject_id
    end
    return false
  end
  
  def teacher?
    self.teaches.size > 0
  end
  
  def teaches?( subject_id )
    for s in self.teaches
      return true if s.id == subject_id
    end
    return false
  end
  
private
  def self.hash_password( password )
    Digest::SHA1.hexdigest(password)
  end
end
