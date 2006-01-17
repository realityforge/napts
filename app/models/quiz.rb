class Quiz < ActiveRecord::Base
  has_many( :quiz_items, :dependent => true )
  has_many( :quiz_attempts, :dependent => true )
  belongs_to( :subject )
  validates_presence_of( :subject_id )
  validates_numericality_of( :duration )
  
  def validate
    errors.add( :duration, "should be positive" ) unless duration > 0
  end
end
