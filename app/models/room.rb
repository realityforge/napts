class Room < ActiveRecord::Base
  validates_length_of( :name, :within => 1..50 )
  validates_uniqueness_of( :name )
  has_many( :computers, :dependent => true )
  has_and_belongs_to_many( :quizzes )
end
