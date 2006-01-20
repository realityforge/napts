class Quiz < ActiveRecord::Base
  has_many( :quiz_items, :dependent => true )
  has_many( :quiz_attempts, :dependent => true )
  has_and_belongs_to_many( :active_in, :class_name => "Room", :join_table => "quizzes_rooms" )
  belongs_to( :subject )
  validates_presence_of( :subject_id )
  validates_uniqueness_of( :name )
  validates_associated( :subject )
  validates_length_of( :name, :within => 1..20 )
  validates_length_of( :description, :within => 1..120 )
  validates_numericality_of( :duration )
  validates_presence_of( :prelim_enable )
  
  def validate
    errors.add( :duration, "should be positive" ) unless duration > 0
  end
end
